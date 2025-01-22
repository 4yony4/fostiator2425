import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignalingService {

  


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RTCPeerConnection? _peerConnection;

  Future<void> initConnection(String roomId) async {
    var config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'turn:34.45.93.254:3478', 'username': 'user', 'credential': 'b852f37fd78662f9ef0c373e2e58889fd796c9af4094faa40c96325eafd20edd'}
      ]
    };

    _peerConnection = await createPeerConnection(config);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _firestore.collection('rooms').doc(roomId).update({
        'candidates': FieldValue.arrayUnion([candidate.toMap()])
      });
    };

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _firestore.collection('rooms').doc(roomId).set({
      'offer': offer.toMap(),
    });
  }
}