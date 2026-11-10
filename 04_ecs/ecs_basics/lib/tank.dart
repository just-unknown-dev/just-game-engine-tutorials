// Parents and children. Run it with
//
//     flutter run -t lib/tank.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Drives the tank round in a circle and turns its turret. After 14
/// seconds it destroys the tank, and everything under it goes too.
class DriveSystem extends System {
  double _time = 0;

  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TransformComponent, TagComponent];

  @override
  void update(double deltaTime) {
    final tank = world.findTagged('tank');
    final turret = world.findTagged('turret');
    if (tank == null || turret == null) return;

    // The tank moves in world space: its TransformComponent.
    final body = tank.getComponent<TransformComponent>()!;
    body.angle += 0.6 * deltaTime;
    body.position.x += cos(body.angle) * 200 * deltaTime;
    body.position.y += sin(body.angle) * 200 * deltaTime;

    // The turret turns on the tank: its local rotation.
    turret.getComponent<ParentComponent>()!.localRotation.z -= 1.4 * deltaTime;

    _time += deltaTime;
    if (_time > 14) world.destroyEntity(tank);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world.addSystem(DriveSystem());

  final tank = world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, -330, 0)),
    Rectangle2DComponent(
      width: 150,
      height: 96,
      cornerRadius: 14,
      fillStyle: const ShapePaintStyle(color: Color(0xFF6B8F4E)),
    ),
    TagComponent('tank'),
  ], name: 'Tank');

  // The turret: a child of the tank, at its centre.
  final turret = world.createEntityWithComponents([
    TransformComponent(),
    ParentComponent(parentId: tank.id, localPosition: Vector3(0, 0, 0)),
    Circle2DComponent(
      radius: 34,
      fillStyle: const ShapePaintStyle(color: Color(0xFF8DB36B)),
    ),
    TagComponent('turret'),
  ], name: 'Turret');

  // The barrel: a child of the turret, 70 units in front of its centre.
  world.createEntityWithComponents([
    TransformComponent(),
    ParentComponent(parentId: turret.id, localPosition: Vector3(70, 0, 0)),
    Rectangle2DComponent(
      width: 80,
      height: 18,
      fillStyle: const ShapePaintStyle(color: Color(0xFF8DB36B)),
    ),
  ], name: 'Barrel');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
