import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class RectangularColision extends PositionComponent with CollisionCallbacks{

  RectangularColision({required super.position,required super.size});

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad


    add(RectangleHitbox(collisionType: CollisionType.passive));

    return super.onLoad();
  }

}