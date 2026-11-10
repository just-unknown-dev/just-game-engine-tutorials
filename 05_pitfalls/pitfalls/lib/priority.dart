// Four: systems run by priority, highest first. Run it with
//
//     flutter run -t lib/priority.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'labels.dart';

/// Swings the box round a circle, fast, by setting its velocity. The
/// movement system (80) then moves it.
class OrbitSystem extends System {
  double angle = 0;

  @override
  int get priority => SystemPriorities.playerControl;

  @override
  List<Type> get requiredComponents => [VelocityComponent];

  @override
  void update(double deltaTime) {
    angle += 5 * deltaTime;
    final box = world.findTagged('box')!;
    box.getComponent<VelocityComponent>()!.velocity
      ..x = -sin(angle) * 1500
      ..y = cos(angle) * 1500;
  }
}

/// Puts a ring where the box is.
class FollowSystem extends System {
  FollowSystem(this.ringName, {required int runAt}) {
    priority = runAt; // before the system is added
  }

  final String ringName;

  @override
  List<Type> get requiredComponents => [TransformComponent];

  @override
  void update(double deltaTime) {
    final box = world.findTagged('box')!;
    final ring = world.findEntityByName(ringName)!;
    ring.getComponent<TransformComponent>()!.position.setFrom(
      box.getComponent<TransformComponent>()!.position,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world
    ..addSystem(OrbitSystem())
    // 85 is above movement (80): it runs first, and reads where the box
    // was before it moved, a step behind.
    ..addSystem(FollowSystem('EarlyRing', runAt: 85))
    // Gameplay (60) runs after movement: the box has moved.
    ..addSystem(FollowSystem('LateRing', runAt: SystemPriorities.gameplay));

  world.createEntityWithComponents([
    TransformComponent(position: Vector3(300, 0, 0)),
    VelocityComponent(),
    Rectangle2DComponent(
      width: 56,
      height: 56,
      cornerRadius: 8,
      fillStyle: const ShapePaintStyle(color: Colors.orange),
    ),
    TagComponent('box'),
  ], name: 'Box');
  for (final (name, color) in [
    ('EarlyRing', const Color(0xFFF5746F)),
    ('LateRing', Colors.white),
  ]) {
    world.createEntityWithComponents([
      TransformComponent(),
      Circle2DComponent(
        radius: 52,
        filled: false,
        strokeWidth: 6,
        strokeStyle: ShapePaintStyle(color: color),
      ),
    ], name: name);
  }

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          engine: engine,
          overlay: labelsAt([
            label(
              'priority 85: before movement',
              0,
              400,
              color: const Color(0xFFF5746F),
            ),
            label('priority 60: after movement', 0, 450),
          ]),
        ),
      ),
    ),
  );
}
