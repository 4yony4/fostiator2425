import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  late WebSocketChannel channel;

  void connect() {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://websocket-server-324006238604.us-central1.run.app'),
    );

    channel.stream.listen(
          (message) {
            print('Received: $message');
          },
          onDone: () {
            print('Connection closed');
          },
          onError: (error) {
            print('Error: $error');
          },
    );

    // Send a test message
    channel.sink.add('Hello from Flutter!');
  }

  void disconnect() {
    channel.sink.close(status.goingAway);
  }
}