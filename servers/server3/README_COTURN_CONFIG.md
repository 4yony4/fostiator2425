# Setting Up Coturn TURN Server with Secret Key

## Step 1: Generate a Secure Secret Key

You can generate a secure key using the following command:

```bash
openssl rand -hex 32
```

Example output:

```
4b8e0f60e6475e8a1f59e2c4a1df4b1b8c3e2f8d9b4c5d8e1a9c7f3a5d2b1e6d
```

Use this value as your `static-auth-secret` in the Coturn configuration.

---

## Step 2: Configure Coturn with the Secret Key

Open the Coturn configuration file:

```bash
sudo nano /etc/turnserver.conf
```

Add or update the following lines:

```plaintext
listening-port=3478
relay-ip=YOUR_VM_IP
fingerprint
use-auth-secret
static-auth-secret=4b8e0f60e6475e8a1f59e2c4a1df4b1b8c3e2f8d9b4c5d8e1a9c7f3a5d2b1e6d
no-loopback-peers
```

Save and exit the file (`Ctrl + X`, then `Y`, and press `Enter`).

---

## Step 3: Restart Coturn Service

After updating the configuration, restart the Coturn server to apply changes:

```bash
sudo systemctl restart coturn
```

---

## Step 4: Using the Secret Key in Your Application

When configuring WebRTC in your Flutter app, use the secret key in the TURN server credentials:

```dart
var configuration = {
  'iceServers': [
    {
      'urls': 'turn:YOUR_VM_IP:3478',
      'username': 'user',
      'credential': '4b8e0f60e6475e8a1f59e2c4a1df4b1b8c3e2f8d9b4c5d8e1a9c7f3a5d2b1e6d'
    }
  ]
};
```

---

## Step 5: Verify the TURN Server is Working

To test if your TURN server is working correctly, you can use the `coturn` test tool or online tools such as [WebRTC Trickle ICE](https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/):

1. Enter your TURN server details (`YOUR_VM_IP`, port `3478`, username, and secret).
2. Click "Gather Candidates" to check if ICE candidates are successfully retrieved.

---

## Conclusion

You have now successfully set up Coturn with a secure secret key and configured it for use in your WebRTC applications.

