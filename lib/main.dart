
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fostiator/Games/FostiatorGame.dart';

import 'Apps/FostiatorApp.dart';
import 'Games/Forge2DExample.dart';
import 'Menus/MainMenu.dart';

void main() async{
  runApp(
    const GameWidget<FostiatorGame>.controlled(
      gameFactory: FostiatorGame.new,
    ),
  );

  /*runApp(
    const GameWidget<Forge2DExample>.controlled(
      gameFactory: Forge2DExample.new,
    ),
  );*/




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
