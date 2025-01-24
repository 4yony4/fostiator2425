import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:crypto/crypto.dart' as crypto;

class CallScreen extends StatefulWidget {
  final String callId;
  final bool isCaller;

  const CallScreen({
    Key? key,
    required this.callId,
    required this.isCaller,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // Renderers for local and remote video
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  // PeerConnection and media stream
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Subscriptions
  StreamSubscription? _offerSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _callerCandidatesSubscription;
  StreamSubscription? _calleeCandidatesSubscription;

  List<RTCIceCandidate> _candidateBuffer = [];

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _startCall();
  }

  @override
  void dispose() {
    _offerSubscription?.cancel();
    _answerSubscription?.cancel();
    _callerCandidatesSubscription?.cancel();
    _calleeCandidatesSubscription?.cancel();

    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.dispose();
    super.dispose();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startCall() async {
    // 1) Create PeerConnection
    await _createPeerConnection();

    // 2) Get user media and add stream to connection
    _localStream = await _getUserMedia();
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // Display local stream
    _localRenderer.srcObject = _localStream;

    // 3) Depending on role (caller / callee), do the offer/answer process
    if (widget.isCaller) {
      await _createOffer();
    } else {
      _listenForOffer(); // If callee, wait for the caller's offer
    }

    // 4) Listen for ICE candidates from remote side
    _listenForRemoteICECandidates();
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    // TURN/STUN server configuration

    final turnCreds = await generateTurnCredentials(secret: "b852f37fd78662f9ef0c373e2e58889fd796c9af4094faa40c96325eafd20edd", realm: "fostiator25.web.app"); // e.g. an HTTPS call

    final configuration = {
      'iceServers': [
        {
          'urls': 'turn:34.45.93.254:3478',
          'username': turnCreds['username'],   // ephemeral username
          'credential': turnCreds['password']  // ephemeral HMAC
        }
      ]
    };
    
    /*final configuration = {
      'iceServers': [
        // Example STUN server:
        {
          'urls': ['stun:stun.l.google.com:19302']
        },
        // Your TURN server:
        {
          'urls': ['turn:34.45.93.254:3478'], // adjust port as needed
          'username': 'admin',
          'credential':'admin'
          //'credential': 'b852f37fd78662f9ef0c373e2e58889fd796c9af4094faa40c96325eafd20edd'
        },
      ]
    };*/

    // Some default constraints
    final Map<String, dynamic> offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    // Create the peer connection
    final pc = await createPeerConnection(configuration, offerSdpConstraints);

    // Listen for local ICE candidates and send them to Firestore
    pc.onIceCandidate = (RTCIceCandidate candidate) {
      print('Local ICE candidate: ${candidate.toMap()}');
      if (candidate.candidate != null) {
        _addCandidateToFirestore(candidate, widget.isCaller ? 'callerCandidates' : 'calleeCandidates');
      }
    };

    // When remote stream arrives, display it
    pc.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteRenderer.srcObject = event.streams.first;
        });
      }
    };

    _peerConnection = pc;
    return pc;
  }

  Future<MediaStream> _getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };
    return await navigator.mediaDevices.getUserMedia(constraints);
  }

  /// Create an offer, set as local description, and save to Firestore
  Future<void> _createOffer() async {
    if (_peerConnection == null) return;

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // Save offer to Firestore
    final offerData = {
      'type': offer.type,
      'sdp': offer.sdp,
    };
    await _firestore.collection('calls').doc(widget.callId).set({
      'offer': offerData,
    });

    // Listen for answer
    _answerSubscription = _firestore
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.data() != null && snapshot.data()!['answer'] != null) {
        final answer = snapshot.data()!['answer'];
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(answer['sdp'], answer['type']),
        );
        print("2222222222------>>>>>>>>>>!!!!!!!!!!!! ");
        // Now that remoteDescription is set, add any buffered candidates
        for (final candidate in _candidateBuffer) {
          await _peerConnection?.addCandidate(candidate);
        }
        _candidateBuffer.clear();
      }
    });
  }

  /// Listen for an offer in Firestore (callee side). Once found, create an answer.
  void _listenForOffer() {
    _offerSubscription = _firestore
        .collection('calls')
        .doc(widget.callId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      // If there's an offer, set remote desc and create answer
      //print("DATA!!!!---->>>>>>   ${_peerConnection?.getRemoteDescription()} ${data['offer']}");
      RTCSessionDescription? description = await _peerConnection?.getRemoteDescription();
      if (data['offer'] != null &&  description == null) {
        final offer = data['offer'];
        //print("DATA!!!!---->>>>>>   $offer");
        final sdp = RTCSessionDescription(offer['sdp'], offer['type']);
        await _peerConnection!.setRemoteDescription(sdp);
        // Now flush the buffer
        for (final candidate in _candidateBuffer) {
          await _peerConnection!.addCandidate(candidate);
        }
        _candidateBuffer.clear();

        //print("DATA!!!!---->>>>>>   1");
        // Now create answer
        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        //print("DATA!!!!---->>>>>>   2");
        final answerData = {
          'type': answer.type,
          'sdp': answer.sdp,
        };

        // Save answer to Firestore
        await _firestore.collection('calls').doc(widget.callId).update({
          'answer': answerData,
        });
      }
    });
  }

  /// Send local ICE candidates to Firestore sub-collection
  Future<void> _addCandidateToFirestore(RTCIceCandidate candidate, String collectionName) async {
    final candidateData = {
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    };

    await _firestore
        .collection('calls')
        .doc(widget.callId)
        .collection(collectionName)
        .add(candidateData);
  }

  /// Listen for remote ICE candidates in Firestore, and add them to our peer connection
  void _listenForRemoteICECandidates() {
    final String collectionName = widget.isCaller ? 'calleeCandidates' : 'callerCandidates';

    _callerCandidatesSubscription = _firestore
        .collection('calls')
        .doc(widget.callId)
        .collection(collectionName)
        .snapshots()
        .listen((snapshot) async {

      // Keep a buffer for candidates


      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final data = doc.doc.data()!;
          RTCIceCandidate candidate = RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
          //_peerConnection?.addCandidate(candidate);
          // Check if remote description is set yet
          RTCSessionDescription? remoteDescription= await _peerConnection?.getRemoteDescription();
          print("111111------>>>>>>>>>>!!!!!!!!!!!!  $remoteDescription");
          if (remoteDescription == null) {
            // Buffer the candidate for later
            _candidateBuffer.add(candidate);
          } else {
            // If remote description is already set, add immediately
            _peerConnection?.addCandidate(candidate);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call: ${widget.callId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: RTCVideoView(_localRenderer, mirror: true),
                ),
                Expanded(
                  child: RTCVideoView(_remoteRenderer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Provide a lifespan for the credentials, e.g., 1 hour from now.
  Map<String, String> generateTurnCredentials({
    required String secret,
    required String realm,
    Duration ttl = const Duration(hours: 1),
  }) {
    // Expiry time (in Unix timestamp format)
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + ttl.inSeconds;

    // The username is typically "timestamp:someOtherValue" but for coturn we just do "timestamp"
    final username = timestamp.toString();

    // The password is HMAC-SHA1 of (username) with key=secret
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