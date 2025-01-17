import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'package:fostiator/Characters/EmberPlayer.dart';
import 'package:fostiator/Colisiones/RectangularColision.dart';

class EmberBody extends BodyComponent with KeyboardHandler, ContactCallbacks{

  final JoystickComponent joystick;
  final Vector2 initialPosition;
  late FixtureDef miFixtureDef;
  late BodyDef miBodyDef;
  late EmberPlayer emberSkin;

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

  int iVidas=3;


  EmberBody(this.joystick,this.initialPosition):super(renderBody: false);

  @override
  Future<void> onLoad() {
    // TODO: implement onLoad
    debugMode=false;

    emberSkin = EmberPlayer( position: Vector2(0, 0));

    add(emberSkin);

    return super.onLoad();
  }

  @override
  Body createBody() {

    // TODO: implement createBody
      miFixtureDef=FixtureDef(
      CircleShape()..radius = 32,
      restitution: 1.8,
      friction: 0.4,
      density: 10
    );

    miBodyDef=BodyDef(
      userData: this,
      angularDamping: 0.8,
      gravityScale: Vector2(0, 30),
      //linearVelocity: Vector2(60, 0),
      position: initialPosition ?? Vector2.zero(),
      type: BodyType.dynamic,
      //gravityOverride: Vector2(0, 500),
    );

    //body.gravityOverride = Vector2(0, 10);
      Body bodytemp=world.createBody(miBodyDef)..createFixture(miFixtureDef);
      //camera.follow(this);

    return bodytemp;
  }



  @override
  void update(double dt) {

    Vector2 aceleracion2D=Vector2(horizontalDirection*300, 0);
    //body.linearVelocity=body.linearVelocity+aceleracion2D;
    body.linearVelocity=Vector2(body.linearVelocity.x+aceleracion2D.x, body.linearVelocity.y+aceleracion2D.y);
    //print("---->>>>>>   ${body.linearVelocity}");

    if (horizontalDirection < 0 && emberSkin.scale.x > 0) {
      emberSkin.flipHorizontally();
    } else if (horizontalDirection > 0 && emberSkin.scale.x < 0) {
      emberSkin.flipHorizontally();
    }
    
    //camera.moveTo(position);

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

    if(hasJumped){

    }

    if(keysPressed.contains(LogicalKeyboardKey.keyG)){
      world.destroyBody(body);
      emberSkin.size=emberSkin.size*2;
      miFixtureDef.shape=CircleShape()..radius = 64;
      body = world.createBody(miBodyDef)..createFixture(miFixtureDef);

    }


    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void beginContact(Object other, Contact contact) {
    //print("HUBO CONTACTO CON EMBER!!!!");
    // TODO: implement beginContact
    if(other is RectangularColision){
     //fixtureDefs?.first.shape=CircleShape()..radius = 128;
      //emberSkin.size=emberSkin.size*2;

    }
    super.beginContact(other, contact);
  }




}