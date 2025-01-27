import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'package:flutter/material.dart';
import 'package:fostiator/Bodies/EmberBody.dart';
import 'package:fostiator/Bodies/MisidraBody.dart';
import 'package:fostiator/Characters/EmberPlayer.dart';
import 'package:fostiator/Characters/Misidra.dart';
import 'package:fostiator/Colisiones/CirularColision.dart';
import 'package:fostiator/DataHolder.dart';

import '../Colisiones/RectangularColision.dart';

class FostiatorGame extends Forge2DGame with HasKeyboardHandlerComponents,HasCollisionDetection{

  late JoystickComponent joystick;
  late EmberBody _emberBody;
  late List<EmberPlayer> _embers=[];
  bool blGameStarted=false;


  FostiatorGame():super(gravity: Vector2(0.0, 10.0));

  @override
  bool get debugMode => false;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
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

    await FlameAudio.audioCache.load('music_back.mp3');

    camera.viewport.add(FpsTextComponent());
    //camera.viewfinder.anchor = Anchor.bottomRight;
    //camera.viewfinder.anchor = Anchor.center;


    TiledComponent mapa1=await TiledComponent.load("mapa1.tmx", Vector2(128, 128));
    //mapa1.scale = vScale;
    await world.add(mapa1);

    // Create the joystick
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 15, paint: Paint()..color = Colors.blue),
      background: CircleComponent(radius: 50, paint: Paint()..color = Colors.blue.withOpacity(0.5)),
      margin: const EdgeInsets.only(left: 20, bottom: 20),
    );


    //_embers.add(EmberBody(joystick,Vector2(50, 100),false));
    _emberBody=EmberBody(joystick,Vector2(50, 100),false);
    //_emberBody2=EmberBody(joystick,Vector2(250, 100));



    //_emberPlayer=EmberPlayer(position: Vector2(50, 100),joystick);


    final objectGroupMisidras = mapa1.tileMap.getLayer<ObjectGroup>('misidras');
    final colisiones_rectangulos = mapa1.tileMap.getLayer<ObjectGroup>('colisiones_rectangulos');
    final colisiones_circulos = mapa1.tileMap.getLayer<ObjectGroup>('colisiones_circulos');

    for (final posMisidraEnMapa in objectGroupMisidras!.objects) {
      await world.add(MisidraBody(Vector2(posMisidraEnMapa.x, posMisidraEnMapa.y)));
    }

    for (final rectColision in colisiones_rectangulos!.objects) {
      await world.add(RectangularColision(Vector2(rectColision.x, rectColision.y),
      Vector2(rectColision.width, rectColision.height)));
    }

    for (final cirColision in colisiones_circulos!.objects) {
      await world.add(CirularColision(position: Vector2(cirColision.x, cirColision.y),
          size: Vector2(cirColision.width, cirColision.height)));
    }


    await add(joystick);

    camera.viewfinder.zoom=0.7;
    camera.viewfinder.anchor=const Anchor(0.1, 0.5);

    //camera.follow(_embers[0]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if(blGameStarted && _embers.length>0){
      //double dist=(_emberBody.position.x-_emberBody2.position.x).abs();
      //double frac=dist/size.x;
      //camera.viewfinder.zoom=1-frac;
      //camera.viewfinder.zoom=getZoom();
      //DataHolder().positionChannel.sendPosition(_embers[0].position.x,_embers[0].position.y);
      DataHolder().positionChannel.sendPosition(_emberBody.position.x,_emberBody.position.y);
    }
  }

  double getZoom(){
    double posXMax=0;
    double posXMin=size.x;
    for(var ember in _embers){
      if(ember.position.x<posXMin)posXMin=ember.position.x;
      if(ember.position.x>posXMax)posXMax=ember.position.x;
    }
    double dist=posXMax-posXMin;
    return dist/size.x;

  }

  void nuevoJuego() async{
    await world.add(_emberBody);

    for(var ember in _embers){
      await world.add(ember);
    }

    //await world.add(_emberBody2);
    camera.follow(_emberBody);
    blGameStarted=true;

    DataHolder().positionChannel.onIncommingPosition=(double x, double y, String id){

      //_embers[1].position=Vector2(x, y);
      //_embers[1].body.position=Vector2(x, y);
      //_embers[1].body.setTransform(Vector2(x, y), _embers[1].body.angle);
      _embers[0].position=Vector2(x, y);
    };


    //DataHolder().positionChannel.sendPosition(100,100);

    //DataHolder().service.sendPosition(100,100);

    //await world.add(_emberBody);
    //camera.follow(_emberBody);

    //camera.follow(_emberBody,snap: true);
    //add(EmberPlayer(position: Vector2(300, 100),joystick));
    //FlameAudio.bgm.play('music_back.mp3', volume: .75);
  }

  void nuevoJugador(){
    //_embers.add(EmberBody(joystick,Vector2(300 , 100),true));
    _embers.add(EmberPlayer(position: Vector2(300 , 100)));
  }

  @override
  Color backgroundColor() => const Color(0xFF00AAE4);

}