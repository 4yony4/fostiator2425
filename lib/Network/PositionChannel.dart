import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:crypto/crypto.dart' as crypto;

class PositionChannel {
  /// Callback for when the data channel is open and ready to send data.
  /// You can set this from outside, e.g.:
  ///   DataHolder().positionChannel.onConnected = () { startGame(); };
  Function? onConnected;
  Function(double x, double y, String id)? onIncommingPosition;

  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firestore subscriptions
  StreamSubscription? _offerSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _callerCandidatesSubscription;
  StreamSubscription? _calleeCandidatesSubscription;

  // Buffer for ICE candidates that arrive before the remote description is set
  final List<RTCIceCandidate> _candidateBuffer = [];

  late bool isCaller;
  late String callId;

  void initConnection(bool isCaller, String callId) {
    this.isCaller = isCaller;
    this.callId = callId;
    _startConnectionFlow();
  }

  void closeChannel() {
    _offerSubscription?.cancel();
    _answerSubscription?.cancel();
    _callerCandidatesSubscription?.cancel();
    _calleeCandidatesSubscription?.cancel();

    _dataChannel?.close();
    _peerConnection?.dispose();
  }

  Future<void> _startConnectionFlow() async {
    // 1) Create PeerConnection
    await _createPeerConnection();

    // 2) Offer/answer logic
    if (isCaller) {
      await _createOffer();
    } else {
      _listenForOffer();
    }

    // 3) Listen for ICE candidates from remote side
    _listenForRemoteICECandidates();
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    // Generate ephemeral TURN credentials (example)
    final turnCreds = _generateTurnCredentials(
      secret: "b852f37fd78662f9ef0c373e2e58889fd796c9af4094faa40c96325eafd20edd",
      realm: "fostiator25.web.app",
    );

    final configuration = {
      'iceServers': [
        {
          'urls': 'turn:34.45.93.254:3478',
          'username': turnCreds['username'],
          'credential': turnCreds['password'],
        },
      ]
    };

    // Some default constraints (data channels are unaffected by these)
    final Map<String, dynamic> offerSdpConstraints = {
      'mandatory': {},
      'optional': [],
    };

    final pc = await createPeerConnection(configuration, offerSdpConstraints);

    // Listen for local ICE candidates and send them to Firestore
    pc.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate != null) {
        _addCandidateToFirestore(
          candidate,
          isCaller ? 'callerCandidates' : 'calleeCandidates',
        );
      }
    };

    // If we are the callee, we need to watch for the remote opening a data channel
    pc.onDataChannel = (RTCDataChannel incomingChannel) {
      _dataChannel = incomingChannel;

      // Watch for state changes. Once it's "open", we can notify that we're connected.
      _dataChannel?.onDataChannelState = (RTCDataChannelState state) {
        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          debugPrint('Data channel is OPEN (callee).');
          onConnected?.call();
        }
      };

      // Listen for incoming messages
      _dataChannel?.onMessage = (RTCDataChannelMessage message) {
        _handleIncomingMessage(message);
      };
    };

    // If we are the caller, create a data channel immediately
    if (isCaller) {
      final dataChannelParams = RTCDataChannelInit();
      // For example, if you want to ensure ordered delivery: dataChannelParams.ordered = true;

      _dataChannel = await pc.createDataChannel('positionChannel', dataChannelParams);

      // Listen for state changes
      _dataChannel?.onDataChannelState = (RTCDataChannelState state) {
        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          debugPrint('Data channel is OPEN (caller).');
          onConnected?.call();
        }
      };

      // Listen for incoming messages
      _dataChannel?.onMessage = (message) {
        _handleIncomingMessage(message);
      };
    }

    _peerConnection = pc;
    return pc;
  }

  /// Create an offer (caller side), set local desc, save to Firestore, then listen for answer.
  Future<void> _createOffer() async {
    if (_peerConnection == null) return;

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // Save offer to Firestore
    final offerData = {
      'type': offer.type,
      'sdp': offer.sdp,
    };
    await _firestore.collection('calls').doc(callId).set({
      'offer': offerData,
    });

    // Listen for answer
    _answerSubscription = _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .listen((snapshot) async {
      final data = snapshot.data();
      if (data == null) return;

      if (data['answer'] != null) {
        final answer = data['answer'];
        final sdp = RTCSessionDescription(answer['sdp'], answer['type']);
        await _peerConnection!.setRemoteDescription(sdp);

        // Now that remoteDescription is set, flush any buffered candidates
        for (final candidate in _candidateBuffer) {
          await _peerConnection!.addCandidate(candidate);
        }
        _candidateBuffer.clear();
      }
    });
  }

  /// Callee: listen for an offer, set remote desc, create answer, set local desc, save answer.
  void _listenForOffer() {
    _offerSubscription = _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;
      final data = snapshot.data();
      if (data == null) return;

      final remoteDesc = await _peerConnection?.getRemoteDescription();

      if (data['offer'] != null && remoteDesc == null) {
        final offer = data['offer'];
        final sdp = RTCSessionDescription(offer['sdp'], offer['type']);
        await _peerConnection!.setRemoteDescription(sdp);

        // Now flush buffered ICE candidates
        for (final candidate in _candidateBuffer) {
          await _peerConnection!.addCandidate(candidate);
        }
        _candidateBuffer.clear();

        // Create answer
        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);

        final answerData = {
          'type': answer.type,
          'sdp': answer.sdp,
        };

        // Save the answer to Firestore
        await _firestore.collection('calls').doc(callId).update({
          'answer': answerData,
        });
      }
    });
  }

  /// ICE candidates come in from remote. Buffer them if remoteDescription is not yet set.
  void _listenForRemoteICECandidates() {
    final collectionName = isCaller ? 'calleeCandidates' : 'callerCandidates';

    _callerCandidatesSubscription = _firestore
        .collection('calls')
        .doc(callId)
        .collection(collectionName)
        .snapshots()
        .listen((snapshot) async {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data();
          if (data == null) continue;

          final candidate = RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );

          final remoteDesc = await _peerConnection?.getRemoteDescription();
          if (remoteDesc == null) {
            _candidateBuffer.add(candidate);
          } else {
            await _peerConnection?.addCandidate(candidate);
          }
        }
      }
    });
  }

  /// Send local ICE candidates to Firestore sub-collection
  Future<void> _addCandidateToFirestore(
      RTCIceCandidate candidate,
      String collectionName
      ) async {
    final candidateData = {
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    };

    await _firestore
        .collection('calls')
        .doc(callId)
        .collection(collectionName)
        .add(candidateData);
  }

  /// Handle an incoming data channel message (JSON with x,y).
  void _handleIncomingMessage(RTCDataChannelMessage message) {
    // This is plain text; parse as JSON
    final data = jsonDecode(message.text);
    final x = data['x'];
    final y = data['y'];
    onIncommingPosition?.call(x,y,"");

    //debugPrint('Received remote position: x=$x, y=$y');
    // TODO: Insert logic here to update your game state with the remote x/y
  }

  /// Public method you can call to send your (x, y) over the data channel.
  void sendPosition(double x, double y) {
    if (_dataChannel == null) {
      debugPrint('No data channel to send position.');
      return;
    }

    final messageMap = {'x': x, 'y': y};
    final messageJson = jsonEncode(messageMap);
    _dataChannel!.send(RTCDataChannelMessage(messageJson));
  }

  /// Example ephemeral TURN credentials generator
  Map<String, String> _generateTurnCredentials({
    required String secret,
    required String realm,
    Duration ttl = const Duration(hours: 1),
  }) {
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + ttl.inSeconds;
    final username = timestamp.toString();

    final hmac = crypto.Hmac(crypto.sha1, utf8.encode(secret));
    final passwordBytes = hmac.convert(utf8.encode(username)).bytes;
    final password = base64.encode(passwordBytes);

    return {
      'username': username,
      'password': password,
      'realm': realm,
    };
  }
}