import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:fostiator/Characters/EmberPlayer.dart';

import '../Games/FostiatorGame.dart';

class Misidra extends SpriteAnimationComponent with HasGameReference<FostiatorGame>, CollisionCallbacks{


  final effect = GlowEffect(
    10.0,
    EffectController(duration: 3),
  );

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

    add(RectangleHitbox(collisionType: CollisionType.passive));
    //add(effect);

    //scale=Vector2(0.5, 0.5);
    //final groundImage = game.images.fromCache('misidra2.png');
    //sprite = Sprite(groundImage);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollisionStart

    if(other is EmberPlayer){
      size*=2;

      //if(intersectionPoints.first.y==(other.y+other.height)){
        //removeFromParent();
      //}

    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // TODO: implement onCollisionEnd
    if(other is EmberPlayer){
      size/=2;
      //if(intersectionPoints.first.y==(other.y+other.height)){
      //removeFromParent();
      //}

    }
    super.onCollisionEnd(other);
  }



}