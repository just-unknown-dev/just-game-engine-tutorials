// Two: +Y is down. Run it with
//
//     flutter run -t lib/axes.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'labels.dart';

/// How fast a ball jumps, along Y.
class JumpComponent extends Component {
  JumpComponent(this.speed);

  final double speed;
}

/// Every 1.5 seconds, sets each ball's Y velocity to its jump speed.
class JumpSystem extends System {
  double _wait = 0.5;

  @override
  int get priority => SystemPriorities.playerControl;

  @override
  List<Type> get requiredComponents => [VelocityComponent, JumpComponent];

  @override
  void update(double deltaTime) {
    _wait -= deltaTime;
    if (_wait > 0) return;
    _wait += 1.5;
    forEach((ball) {
      final jump = ball.getComponent<JumpComponent>()!;
      ball.getComponent<VelocityComponent>()!.velocity.y = jump.speed;
    });
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world.addSystem(JumpSystem());
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 260, 0)),
    Rectangle2DComponent(width: 1400, height: 30),
    Collider2DComponent(shape: Collider2DShape.matchShape),
  ], name: 'Floor');

  // Wrong: +Y is down, so this pushes the ball into the floor.
  // Right: a jump is -Y.
  for (final (x, speed, color) in [
    (-400.0, 700.0, const Color(0xFFF5746F)),
    (400.0, -700.0, Colors.lightBlue),
  ]) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 200, 0)),
      Circle2DComponent(radius: 40, fillStyle: ShapePaintStyle(color: color)),
      VelocityComponent(),
      RigidBody2DComponent(),
      Collider2DComponent(shape: Collider2DShape.matchShape),
      JumpComponent(speed),
    ], name: 'Ball');
  }

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          engine: engine,
          overlay: labelsAt([
            label(
              'velocity.y = +700',
              -400,
              340,
              color: const Color(0xFFF5746F),
            ),
            label('velocity.y = -700', 400, 340, color: Colors.lightBlue),
          ]),
        ),
      ),
    ),
  );
}
