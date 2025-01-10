import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fostiator/Games/FostiatorGame.dart';

class EmberPlayer extends SpriteAnimationComponent
    with HasGameReference<FostiatorGame>, KeyboardHandler {

  int horizontalDirection = 0;
  final Vector2 velocidad = Vector2.zero();
  final double aceleracion = 200;

  final double gravity = 15;
  final double jumpSpeed = 600;
  final double terminalVelocity = 150;

  bool hasJumped = false;

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
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);

    velocidad.x = horizontalDirection * aceleracion ;
    velocidad.y+=gravity;

    // Determine if ember has jumped
    if (hasJumped) {
      //if (isOnGround) {
        velocidad.y = -jumpSpeed;
        //isOnGround = false;
      //}
      hasJumped = false;
    }

  // Prevent ember from jumping to crazy fast as well as descending too fast and
  // crashing through the ground or a platform.
    velocidad.y = velocidad.y.clamp(-jumpSpeed, terminalVelocity);

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

    if(keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)){
      horizontalDirection=1;
    }

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }
}