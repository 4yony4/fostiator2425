import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:fostiator/Characters/EmberPlayer.dart';

import '../Games/FostiatorGame.dart';

class Misidra extends SpriteAnimationComponent with HasGameReference<FostiatorGame>, CollisionCallbacks{


  List<SpriteAnimation> animaciones=[];
  int I_ANIMACION_NORMAL=0;
  int I_ANIMACION_TOCADO=1;

  final effect = GlowEffect(
    10.0,
    EffectController(duration: 3),
  );

  Misidra({required super.position,}):super(size: Vector2(100,100), anchor: Anchor.center);

  @override
  void onLoad() {

    animaciones.add(SpriteAnimation.fromFrameData(
      game.images.fromCache('misidra3.png'),
      SpriteAnimationData.sequenced(
        amount: 2,
        textureSize: Vector2(246,246),
        stepTime: 0.52,
      ),
    ));

    animaciones.add(SpriteAnimation.fromFrameData(
      game.images.fromCache('misidra3.png'),
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: Vector2(246,246),
        stepTime: 0.52,
      ),
    ));

    animation=animaciones[0];

    add(RectangleHitbox(collisionType: CollisionType.passive));
    //add(effect);

    //scale=Vector2(0.5, 0.5);
    //final groundImage = game.images.fromCache('misidra2.png');
    //sprite = Sprite(groundImage);
  }

  void setAnimacion(int estado){
    animation=animaciones[estado];
  }


}