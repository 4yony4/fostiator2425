import 'package:flame/components.dart';

import '../Games/FostiatorGame.dart';

class Misidra extends SpriteComponent with HasGameReference<FostiatorGame>{

  Misidra({required super.position,}):super(size: Vector2(300,300), anchor: Anchor.center);

  @override
  void onLoad() {
    final groundImage = game.images.fromCache('misidra.jpeg');
    sprite = Sprite(groundImage);
  }

}