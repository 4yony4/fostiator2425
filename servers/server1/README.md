# Pure WebSocket Solution Using Google Cloud Run

## 1. Set Up Firebase and Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com).
2. Select your Firebase project (or create a new one).
3. Enable Cloud Run service:
   - Navigate to **APIs & Services > Enable APIs and Services**.
   - Search for **Cloud Run API** and enable it.

## 2. Install Required Tools

You’ll need to install the Firebase and Google Cloud CLI:

```sh
npm install -g firebase-tools
gcloud auth login
firebase login
```

## 3. Create WebSocket Server (Node.js)

Create a new folder and inside it, create the following files:

### package.json (for dependencies)

```json
{
  "name": "websocket-server",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "ws": "^8.16.0"
  },
  "scripts": {
    "start": "node server.js"
  }
}
```

### server.js (WebSocket server logic)

```js
const WebSocket = require('ws');

const PORT = process.env.PORT || 8080;
const wss = new WebSocket.Server({ port: PORT });

console.log(`WebSocket server running on port ${PORT}`);

wss.on('connection', (ws) => {
  console.log('New client connected');

  ws.on('message', (message) => {
    console.log(`Received: ${message}`);

    // Broadcast the message to all connected clients
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(`Echo: ${message}`);
      }
    });
  });

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});
```

## 4. Create a Dockerfile

Firebase Cloud Run requires a containerized app. Create a `Dockerfile` in the same directory:

```dockerfile
# Use Node.js official image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the app files
COPY . .

# Expose the port
EXPOSE 8080

# Start the WebSocket server
CMD ["npm", "start"]
```

## 5. Deploy WebSocket Server to Cloud Run

1. Build and push your Docker container:

   ```sh
   gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/websocket-server
   ```

2. Deploy the container to Cloud Run:

   ```sh
   gcloud run deploy websocket-server \
     --image gcr.io/YOUR_PROJECT_ID/websocket-server \
     --platform managed \
     --allow-unauthenticated \
     --port 8080 \
     --region us-central1
   ```

3. Once deployed, Google Cloud Run will provide a URL, such as:

   ```
   https://websocket-server-xyz-uc.a.run.app
   ```

## 6. Connect to WebSocket from Flutter

In your Flutter project, add the `web_socket_channel` package:

```sh
flutter pub add web_socket_channel
```

Now, create a function to connect to your WebSocket server:

```dart
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  late WebSocketChannel channel;

  void connect() {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://websocket-server-xyz-uc.a.run.app'),
    );

    channel.stream.listen(
      (message) {
        print('Received: \$message');
      },
      onDone: () {
        print('Connection closed');
      },
      onError: (error) {
        print('Error: \$error');
      },
    );

    // Send a test message
    channel.sink.add('Hello from Flutter!');
  }

  void disconnect() {
    channel.sink.close(status.goingAway);
  }
}
```

## 7. Running the App

1. Run the Flutter app with `flutter run`.
2. It should connect to your WebSocket server and send a message.
3. You should see responses in the terminal logs.

## 8. Firebase Pricing (Cloud Run Free Tier)

Google Cloud Run free tier includes:

- 2 million requests per month.
- 360,000 CPU seconds per month.
- 1GB network egress per month.

🔗 [Cloud Run Pricing](https://cloud.google.com/run/pricing)

## 9. Optimizing Deployment Process

To quickly update the `server.js` code, follow these optimized steps:

```sh
# Navigate to your project folder
cd /path/to/your/project

# Rebuild the Docker image (optimized to use cache)
docker build -t gcr.io/YOUR_PROJECT_ID/websocket-server .

# Push the updated image to Google Container Registry (GCR)
docker push gcr.io/YOUR_PROJECT_ID/websocket-server

# Deploy the updated container to Cloud Run
gcloud run deploy websocket-server \
  --image gcr.io/YOUR_PROJECT_ID/websocket-server \
  --platform managed \
  --allow-unauthenticated \
  --region us-central1
```

## 10. Rolling Back to Previous Version

If something goes wrong with your update:

1. Go to the **Google Cloud Run Console**.
2. Click on your service.
3. Under “Revisions”, select the previous deployment and click **Deploy Traffic** to revert.

## Summary of Steps

1. Set up Firebase and Google Cloud project.
2. Create WebSocket server in Node.js.
3. Containerize the app using Docker.
4. Deploy to Google Cloud Run.
5. Connect from Flutter using WebSocketChannel.
6. Optimize deployment for quick updates.
7. Monitor and rollback using Cloud Run.

## Conclusion

This guide provides a complete setup for hosting a pure WebSocket solution using Google Cloud Run with Firebase, offering:

- Low latency real-time communication.
- Automatic scaling and serverless operation.
- Free-tier usage for small-scale applications.
