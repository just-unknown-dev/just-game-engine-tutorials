import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The standard systems: input, physics, movement, audio, rendering,
  // sprites, animators, timelines, level maps, map collision, cameras.
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  // The camera's position is the world point in the middle of the screen.
  engine.camera.mainCamera
    ..lookAt(Offset.zero)
    ..zoom = 1.0;

  final world = engine.world;
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-150, 0, 0)),
    Circle2DComponent(
      radius: 40,
      fillStyle: const ShapePaintStyle(color: Colors.lightBlue),
    ),
  ], name: 'Sun');

  // +Y is down: this box drifts towards the bottom of the screen.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(150, -100, 0), angle: 0.3),
    VelocityComponent(velocity: Vector3(0, 40, 0)),
    Rectangle2DComponent(
      width: 120,
      height: 60,
      cornerRadius: 8,
      fillStyle: const ShapePaintStyle(color: Colors.orange),
    ),
  ], name: 'Box');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
