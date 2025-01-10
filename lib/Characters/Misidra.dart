import 'package:flame/components.dart';

import '../Games/FostiatorGame.dart';

class Misidra extends SpriteAnimationComponent with HasGameReference<FostiatorGame>{

  Misidra({required super.position,}):super(size: Vector2(100,100), anchor: Anchor.center);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('misidra3.png'),
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: Vector2(246,246),
        stepTime: 0.52,
      ),
    );

    //scale=Vector2(0.5, 0.5);
    //final groundImage = game.images.fromCache('misidra2.png');
    //sprite = Sprite(groundImage);
  }

}