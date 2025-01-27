
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fostiator/Apps/P2PApp.dart';
import 'package:fostiator/Games/FostiatorGame.dart';
import 'package:fostiator/Network/WebSocketService.dart';

import 'Apps/FostiatorApp.dart';
import 'Games/Forge2DExample.dart';
import 'Menus/MainMenu.dart';
import 'firebase_options.dart';

void main() async{
  /*runApp(
    const GameWidget<FostiatorGame>.controlled(
      gameFactory: FostiatorGame.new,
    ),
  );

  WebSocketService wss=WebSocketService();
  wss.connect();*/

  /*runApp(
    const GameWidget<Forge2DExample>.controlled(
      gameFactory: Forge2DExample.new,
    ),
  );*/


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);



  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          game: FostiatorGame(),
          overlayBuilderMap: {
            'MainMenu': (context, FostiatorGame game) {
              return MainMenu(
                game: game,
              );
            },
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    ),
  );

  //runApp(const P2pApp());
    /*runApp(
      GameWidget<FostiatorGame>.controlled(
        gameFactory: FostiatorGame.new,
        overlayBuilderMap: {
          'MainMenu': (_, game) => MainMenu(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );*/

    //WidgetsFlutterBinding.ensureInitialized();

    // Initialize the camera
    //final cameras = await availableCameras();
    //final firstCamera = cameras.first;

    //runApp(FostiatorApp(camera: firstCamera));


}
