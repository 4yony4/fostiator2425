import 'package:flutter/material.dart';

import 'CallScreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _callIdController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebRTC P2P Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _callIdController,
              decoration: const InputDecoration(labelText: 'Call ID'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final callId = _callIdController.text.trim();
                if (callId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallScreen(callId: callId, isCaller: true),
                    ),
                  );
                }
              },
              child: const Text('Create Call (Caller)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final callId = _callIdController.text.trim();
                if (callId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallScreen(callId: callId, isCaller: false),
                    ),
                  );
                }
              },
              child: const Text('Join Call (Callee)'),
            ),
          ],
        ),
      ),
    );
  }
}