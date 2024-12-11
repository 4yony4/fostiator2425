import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fostiator/Games/FostiatorGame.dart';

class EmberPlayer extends SpriteAnimationComponent
    with HasGameReference<FostiatorGame>, KeyboardHandler {
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
    //x=x+10;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // TODO: implement onKeyEvent

    x=x+10;

    return super.onKeyEvent(event, keysPressed);
  }
}