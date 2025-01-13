import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CirularColision extends PositionComponent with CollisionCallbacks{

  CirularColision({required super.position,required super.size});

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad


    //add(RectangleHitbox(collisionType: CollisionType.passive));
    add(CircleHitbox(collisionType: CollisionType.passive));


    return super.onLoad();
  }

}