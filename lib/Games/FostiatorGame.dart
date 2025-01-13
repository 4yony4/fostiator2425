import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:fostiator/Characters/EmberPlayer.dart';
import 'package:fostiator/Characters/Misidra.dart';

import '../Colisiones/RectangularColision.dart';

class FostiatorGame extends FlameGame with HasKeyboardHandlerComponents,HasCollisionDetection{

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
      'misidra2.png',
      'misidra3.png',
    ]);

    camera.viewfinder.anchor = Anchor.topLeft;


    TiledComponent mapa1=await TiledComponent.load("mapa1.tmx", Vector2(128, 128));
    mapa1.scale = Vector2(0.5, 0.4);
    add(mapa1);

    _emberPlayer=EmberPlayer(position: Vector2(50, 100));
    add(_emberPlayer);
    add(EmberPlayer(position: Vector2(300, 100)));

    final objectGroupMisidras = mapa1.tileMap.getLayer<ObjectGroup>('misidras');
    final colisiones_rectangulos = mapa1.tileMap.getLayer<ObjectGroup>('colisiones_rectangulos');

    for (final posMisidraEnMapa in objectGroupMisidras!.objects) {
      add(Misidra(position: Vector2(posMisidraEnMapa.x*0.5, posMisidraEnMapa.y*0.4)));
    }

    for (final rectColision in colisiones_rectangulos!.objects) {
      add(RectangularColision(position: Vector2(rectColision.x*0.5, rectColision.y*0.4),
      size: Vector2(rectColision.width*0.5, rectColision.height*0.4)));
    }

    /*
    _misidra=Misidra(position: Vector2(500, 100));
    add(_misidra);
*/
    //camera.viewfinder.zoom = 0.25;

    return super.onLoad();
  }

  @override
  Color backgroundColor() => const Color(0xFF00AAE4);

}