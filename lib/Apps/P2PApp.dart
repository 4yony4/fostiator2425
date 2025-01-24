import 'package:flutter/material.dart';
import 'P2PApp/HomeScreen.dart';

class P2pApp extends StatelessWidget {
  const P2pApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebRTC P2P Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}