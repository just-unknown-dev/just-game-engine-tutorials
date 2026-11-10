// The floor and the ball: run it with
//
//     flutter run -t lib/ball.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The engine, with its standard systems.
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  // y points down, and (0, 0) is the middle of the screen until a
  // virtual camera takes over.
  engine.world
    ..createEntityWithComponents([
      TransformComponent(position: Vector3(0, 200, 0)),
      Rectangle2DComponent(width: 600, height: 24),
      // A collider alone is a static body; this one is the drawn rectangle.
      Collider2DComponent(shape: Collider2DShape.matchShape),
    ], name: 'Floor')
    ..createEntityWithComponents([
      TransformComponent(position: Vector3(0, -150, 0)),
      Circle2DComponent(radius: 24),
      RigidBody2DComponent(),
      Collider2DComponent(shape: Collider2DShape.matchShape),
    ], name: 'Ball');

  engine.start();
  runApp(MaterialApp(home: Scaffold(body: GameWidget(engine: engine))));
}
