import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:fostiator/Games/FostiatorGame.dart';

void main() {
  runApp(
    const GameWidget<FostiatorGame>.controlled(
      gameFactory: FostiatorGame.new,
    ),
  );

}
