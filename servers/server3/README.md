# Hybrid P2P Multiplayer Solution using Flutter, Firebase, and Google Cloud

## Overview
In this guide, you'll set up a **Hybrid P2P Multiplayer Solution** using **Flutter**, **Firebase**, and **Google Cloud**, which involves:

1. **Firebase Firestore** for matchmaking and signaling.
2. **WebRTC** for direct P2P data exchange.
3. **Google Cloud (TURN/STUN)** to ensure connectivity behind NAT/firewalls.
4. **Firebase Cloud Functions** for advanced matchmaking logic.

---

## Step 1: Set Up Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Enable the following services:
   - **Authentication**
   - **Firestore Database**
   - **Cloud Functions** (optional)

3. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

4. Add Firebase dependencies to your Flutter project:
   ```yaml
   dependencies:
     firebase_core: latest_version
     cloud_firestore: latest_version
     firebase_auth: latest_version
     flutter_webrtc: latest_version
   ```

5. Initialize Firebase in your Flutter app:
   ```dart
   import 'package:firebase_core/firebase_core.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     runApp(MyApp());
   }
   ```

---

## Step 2: Set Up Google Cloud TURN/STUN Server

0. Setear el proyecto asignado a la carpeta al proyecto de Google Cloud:
   ```bash
   gcloud auth login
   gcloud config set project PROJECT_ID
   ```

1. Create a Virtual Machine (VM) in Google Cloud:
   Creamos la instancia de la MV en Google Cloud, se puede ver en
   https://console.cloud.google.com/compute/instances?referrer=search&inv=1&invt=Abngfw&project=fostiator25
      ```bash
      gcloud compute instances create turn-server \
          --machine-type=n1-standard-1 \
          --image-project=debian-cloud \
          --image-family=debian-12 \
          --tags=turn
      ```
   Conectamos la console de mi ordenador por SSH a la VM para poder operar los comandos de SUDO.
      ```bash
      gcloud compute ssh VM_NAME
      ```

2. Install Coturn TURN server:
   ```bash
   sudo apt update && sudo apt install coturn -y
   ```

3. Configure Coturn in `/etc/turnserver.conf`:
   ```plaintext
   listening-port=3478
   relay-ip=YOUR_VM_IP
   fingerprint
   use-auth-secret
   static-auth-secret=YOUR_SECRET_KEY
   no-loopback-peers
   ```
   VER MAS EN EL FICHERO: README_COTURN_CONFIG.MD ( PARA GENERAR LA static-auth-secret)

4. Enable and restart Coturn:
   ```bash
   sudo systemctl enable coturn
   sudo systemctl restart coturn
   ```

5. Open firewall for TURN/STUN ports:
   ```bash
   gcloud compute firewall-rules create turn-udp --allow udp:3478
   gcloud compute firewall-rules create turn-tcp --allow tcp:3478
   ```

---

## Step 3: Implement Signaling Using Firebase Firestore

1. Create a Firestore collection `rooms` for matchmaking.
2. Implement signaling in Flutter:
   ```dart
   import 'package:flutter_webrtc/flutter_webrtc.dart';
   import 'package:cloud_firestore/cloud_firestore.dart';

   class SignalingService {
     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
     RTCPeerConnection? _peerConnection;

     Future<void> initConnection(String roomId) async {
       var config = {
         'iceServers': [
           {'urls': 'stun:stun.l.google.com:19302'},
           {'urls': 'turn:YOUR_VM_IP:3478', 'username': 'user', 'credential': 'YOUR_SECRET_KEY'}
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
   ```

---

## Step 4: User Authentication and Matchmaking

Enable Firebase Authentication and use Cloud Functions for matchmaking:

Example Firebase Cloud Function to create a room:

```javascript
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.createRoom = functions.https.onCall(async (data, context) => {
  const roomRef = admin.firestore().collection("rooms").doc();
  await roomRef.set({
    host: context.auth.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    status: "waiting",
  });
  return { roomId: roomRef.id };
});
```

---

## Step 5: Integrate P2P Game Logic

Once WebRTC is connected, exchange game data directly:

```dart
_peerConnection!.dataChannel?.send(RTCDataChannelMessage('{"action": "move", "x": 10, "y": 20"}'));

_peerConnection!.dataChannel?.onMessage = (message) {
  print("Received: ${message.text}");
};
```

---

## Step 6: Deploy and Test

1. Run Firebase Emulators:
   ```bash
   firebase emulators:start
   ```

2. Deploy Firebase Cloud Functions:
   ```bash
   firebase deploy --only functions
   ```

---

## Step 7: Security and Optimization

Secure Firestore with rules:

```json
service cloud.firestore {
  match /databases/{database}/documents {
    match /rooms/{roomId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Optimize WebRTC settings for low-latency:

```dart
var config = {
  'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}],
  'sdpSemantics': 'unified-plan',
};
```

---

## Conclusion

You have now set up a hybrid P2P multiplayer system with:

1. **Firebase** for signaling and matchmaking.
2. **Google Cloud TURN/STUN** for NAT traversal.
3. **Flutter WebRTC** for direct peer-to-peer communication.
4. **Firebase Auth** for secure matchmaking.

---

### Need Help?
If you encounter any issues, check the official documentation:
- [Flutter WebRTC](https://pub.dev/packages/flutter_webrtc)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Google Cloud Compute](https://cloud.google.com/compute/docs/)
