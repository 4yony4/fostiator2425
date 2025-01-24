import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignalingService {

  


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RTCPeerConnection? _peerConnection;
  late RTCDataChannel dataChannel;

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

  void createOffer(String roomId) async {
    var config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'turn:34.45.93.254:3478', 'username': 'user', 'credential': 'b852f37fd78662f9ef0c373e2e58889fd796c9af4094faa40c96325eafd20edd'}
      ]
    };

    RTCPeerConnection _peerConnection = await createPeerConnection(config);

    // Create a data channel for alerts
    RTCDataChannelInit dataChannelInit = RTCDataChannelInit();
     dataChannel = await _peerConnection.createDataChannel("DataChannel1", dataChannelInit);

    // Send an alert when user joins
    dataChannel.onDataChannelState = (state) {
      print("Data channel state: $state");
      dataChannel.send(RTCDataChannelMessage("User joined the room ${state}"));

      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print("Data channel is now open and ready to send data!");
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print("Peer connection established successfully!");
      }
    };



    RTCSessionDescription offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);

    // Store offer in Firestore
    FirebaseFirestore.instance.collection('rooms').doc(roomId).set({
      'offer': offer.toMap(),
    });


    FirebaseFirestore.instance.collection('rooms').doc(roomId).collection('users')
        .snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          dataChannel.send(RTCDataChannelMessage("A new user has joined the room"));
        }
      });
    });
  }

  void updateRoomOnJoin(String roomId, String userId) async {
    FirebaseFirestore.instance.collection('rooms').doc(roomId).collection('users').doc(userId).set({
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  void joinRoom(String roomId) async {
    var config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'turn:34.45.93.254:3478', 'username': 'user', 'credential': 'b852f37fd78662f9ef0c373e2e58889fd796c9af4094faa40c96325eafd20edd'}
      ]
    };

    RTCPeerConnection _peerConnection = await createPeerConnection(config);

    // Listen for incoming data channel
    _peerConnection.onDataChannel = (RTCDataChannel channel) {
      dataChannel=channel;
      dataChannel.onDataChannelState = (state) {

        dataChannel.send(RTCDataChannelMessage("User joined the room ${state}"));
        print("Data channel state: $state");
        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          print("Data channel is now open and ready to send data!");
        }
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          print("Peer connection established successfully!");
        }
      };

      channel.onMessage = (RTCDataChannelMessage message) {
        print("Alert received: ${message.text}");
        // Show an alert dialog in Flutter UI
      };
    };





    DocumentSnapshot roomSnapshot =
    await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();

    if (roomSnapshot.exists) {
      RTCSessionDescription offer = RTCSessionDescription(
        roomSnapshot['offer']['sdp'],
        roomSnapshot['offer']['type'],
      );

      await _peerConnection.setRemoteDescription(offer);
      RTCSessionDescription answer = await _peerConnection.createAnswer();
      await _peerConnection.setLocalDescription(answer);

      FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        'answer': answer.toMap(),
      });
    }
  }

  void sendPosition(double x, double y) {
    //final positionData = {'x': x, 'y': y};
    //String jsonString = jsonEncode(positionData);
    //dataChannel.send(RTCDataChannelMessage(jsonString));
    if (dataChannel.state == RTCDataChannelState.RTCDataChannelOpen) {
      final positionData = {'x': x, 'y': y};
      String jsonString = jsonEncode(positionData);
      dataChannel.send(RTCDataChannelMessage(jsonString));
    } else {
      print("Data channel not open yet. Current state: ${dataChannel.state}");
    }
  }

  Future<void> sendWithRetry(RTCDataChannel channel, double x, double y) async {
    for (int i = 0; i < 5; i++) {
      if (channel.state == RTCDataChannelState.RTCDataChannelOpen) {
        channel.send(RTCDataChannelMessage(jsonEncode({'x': x, 'y': y})));
        return;
      }
      await Future.delayed(Duration(milliseconds: 500));
    }
    print("Failed to send data after multiple attempts. Channel state: ${channel.state}");
  }


  void setupDataChannel(RTCPeerConnection peerConnection) async {

    dataChannel.onDataChannelState = (state) {
      print("Data channel state: $state");
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print("Data channel is now open and ready to send data!");
      }
    };
  }

  /*
  void showUserJoinAlert(String message) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Text("Notification"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            )
          ],
        );
      },
    );
  }

   */

}