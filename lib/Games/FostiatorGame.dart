import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:fostiator/Characters/EmberPlayer.dart';
import 'package:fostiator/Characters/Misidra.dart';

class FostiatorGame extends FlameGame with HasKeyboardHandlerComponents{

  late EmberPlayer _emberPlayer;
  late Misidra _misidra;

  @override
  FutureOr<void> onLoad() async {
    // TODO: implement onLoad

    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png',
      'misidra.jpeg',
    ]);

    camera.viewfinder.anchor = Anchor.topLeft;

    _emberPlayer=EmberPlayer(position: Vector2(50, 100));
    add(_emberPlayer);

    _misidra=Misidra(position: Vector2(500, 100));
    add(_misidra);

    add(Misidra(position: Vector2(700, 100)));
    add(Misidra(position: Vector2(700, 300)));

    return super.onLoad();
  }

}