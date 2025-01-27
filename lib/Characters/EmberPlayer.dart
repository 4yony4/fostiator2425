import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fostiator/Characters/Misidra.dart';
import 'package:fostiator/Colisiones/CirularColision.dart';
import 'package:fostiator/Colisiones/RectangularColision.dart';
import 'package:fostiator/Games/FostiatorGame.dart';

class EmberPlayer extends SpriteAnimationComponent
    with HasGameReference<FostiatorGame>, KeyboardHandler, CollisionCallbacks {


  final bool blMainPlayer;

  EmberPlayer(this.blMainPlayer, {required super.position,}) :
        super(size: Vector2(64,64), anchor: Anchor.center);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(blMainPlayer?'ember.png':'ember2.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );

    //add(CircleHitbox(collisionType: CollisionType.active));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);

    //position.add(joystick.delta * dt);

    /*velocidad.x = horizontalDirection * aceleracion ;
    double temp=gravity;
    if (isOnGround) {
      temp=0;
    }

    // Determine if ember has jumped
    if (hasJumped) {
      //if (isOnGround) {
        velocidad.y = -jumpSpeed;
        //isOnGround=false;
      //}
      hasJumped = false;
    }



  // Prevent ember from jumping to crazy fast as well as descending too fast and
  // crashing through the ground or a platform.
    velocidad.y += temp;
    velocidad.y = velocidad.y.clamp(-jumpSpeed, temp);


    //print("------->>>>>>>>>>>>>>>> UPDATE: $velocidad");

    position += velocidad * dt;


    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally();
    }*/

  }

  /*

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollisionStart

    if(other is Misidra){
      iVidas--;
      hit();
      if(iVidas<=0){
        removeFromParent();
      }
    }

    if(other is CirularColision){
      //print("INTRESCCION: $intersectionPoints Y EL OTHER: ${other.position} SIZE: ${other.size}");
      //print("HEY HEY HEY!!!!");
    }

    if(other is RectangularColision){
      //print("INTRESCCION: $intersectionPoints Y EL OTHER: ${other.position} SIZE: ${other.size}");

      //if(other.y-5<intersectionPoints[] &&)
      if(other.y == intersectionPoints.first.y){
        isOnGround=true;
      }
      else if(other.x == intersectionPoints.first.x){
        isRightWall=true;
      }
      else if((other.x+other.width) == intersectionPoints.first.x){
        isLeftWall=true;
      }

    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // TODO: implement onCollisionEnd
    if(other is RectangularColision){
      isOnGround=false;
      isRightWall=false;
      isLeftWall=false;
    }

    super.onCollisionEnd(other);
  }

  void hit() {
    if (!hitByEnemy) {
      hitByEnemy = true;
    }
    add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.1,
          repeatCount: 6,
        ),
      )..onComplete = () {
        hitByEnemy = false;
      },
    );
  }
*/

}