import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fostiator/Colisiones/RectangularColision.dart';
import 'package:fostiator/Games/FostiatorGame.dart';

class EmberPlayer extends SpriteAnimationComponent
    with HasGameReference<FostiatorGame>, KeyboardHandler, CollisionCallbacks {

  int horizontalDirection = 0;
  final Vector2 velocidad = Vector2.zero();
  final double aceleracion = 200;

  final double gravity = 50;
  final double jumpSpeed = 600;
  //final double terminalVelocity = 150;

  bool hasJumped = false;
  bool isOnGround=false;
  bool isRightWall=false;
  bool isLeftWall=false;

  EmberPlayer({required super.position,}) :
        super(size: Vector2(64,64), anchor: Anchor.center);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('ember.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );

    add(CircleHitbox(collisionType: CollisionType.active));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);

    velocidad.x = horizontalDirection * aceleracion ;
    double temp=gravity;
    if (isOnGround) {
      temp=0;
    }

    // Determine if ember has jumped
    if (hasJumped) {
      if (isOnGround) {
        velocidad.y = -jumpSpeed;
        isOnGround=false;
      }
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
    }

  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // TODO: implement onKeyEvent

    horizontalDirection = 0;

    if(keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)){
      horizontalDirection=-1;
    }

    if((keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) && !isRightWall){
      horizontalDirection=1;
    }

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollisionStart

    if(other is RectangularColision){
      print("INTRESCCION: $intersectionPoints Y EL OTHER: ${other.position} SIZE: ${other.size}");

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


}