import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:fostiator/Bodies/EmberBody.dart';
import 'package:fostiator/Characters/EmberPlayer.dart';
import 'package:fostiator/Characters/Misidra.dart';
import 'package:fostiator/Colisiones/RectangularColision.dart';

class MisidraBody extends BodyComponent with KeyboardHandler, ContactCallbacks{


  final Vector2 initialPosition;
  late FixtureDef miFixtureDef;
  late BodyDef miBodyDef;
  late Misidra misidraSkin;

  int horizontalDirection = 0;
  final Vector2 velocidad = Vector2.zero();
  final double aceleracion = 200;

  final double gravity = 0;
  final double jumpSpeed = 600;
  //final double terminalVelocity = 150;

  bool hasJumped = false;
  bool isOnGround=false;
  bool isRightWall=false;
  bool isLeftWall=false;
  bool hitByEnemy=false;




  MisidraBody(this.initialPosition):super(renderBody: false);

  @override
  Future<void> onLoad() {
    // TODO: implement onLoad
    debugMode=false;

    misidraSkin = Misidra( position: Vector2(0, 0));

    add(misidraSkin);

    return super.onLoad();
  }

  @override
  Body createBody() {

    // TODO: implement createBody
    miFixtureDef=FixtureDef(
        CircleShape()..radius = 50,
        restitution: 1.8,
        friction: 0.4,
        density: 10
    );

    miBodyDef=BodyDef(
      userData: this,
      angularDamping: 0.8,
      //linearVelocity: Vector2(60, 0),
      position: initialPosition ?? Vector2.zero(),
      type: BodyType.kinematic,
      //gravityOverride: Vector2(0, 500),
    );

    //body.gravityOverride = Vector2(0, 10);
    Body bodytemp=world.createBody(miBodyDef)..createFixture(miFixtureDef);
    //camera.follow(this);

    return bodytemp;
  }



  @override
  void update(double dt) {
  }


  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);

    print("CHOQUE CON: $other");

    if(other is EmberBody){
      misidraSkin.scale=Vector2(2, 2);
      misidraSkin.setAnimacion(misidraSkin.I_ANIMACION_TOCADO);
      //body.angularVelocity=50;
    }

  }


}