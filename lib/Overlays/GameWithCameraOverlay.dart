/*
import 'package:camera/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fostiator/Games/FostiatorGame.dart';

class GameWithCameraOverlay extends StatefulWidget {
  final CameraDescription camera;

  const GameWithCameraOverlay({Key? key, required this.camera}) : super(key: key);

  @override
  _GameWithCameraOverlayState createState() => _GameWithCameraOverlayState();
}

class _GameWithCameraOverlayState extends State<GameWithCameraOverlay> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera feed as the background
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),

          // The GameWidget as the top layer
          GameWidget(game: FostiatorGame()),
        ],
      ),
    );
  }
}

 */