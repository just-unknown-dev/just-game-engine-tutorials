// A prefab in code. Run it with
//
//     flutter run -t lib/bullets.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// A bullet. Each copy gets fresh components from these factories.
final bullet = EntityPrefab(
  name: 'Bullet',
  factories: [
    () => TransformComponent(),
    () => VelocityComponent(velocity: Vector3(700, 0, 0)),
    () => Circle2DComponent(
      radius: 9,
      fillStyle: const ShapePaintStyle(color: Colors.amber),
    ),
    () => LifetimeComponent(2.5), // gone after 2.5 seconds
  ],
);

Entity fire(World world, Vector3 muzzle) {
  final shot = world.instantiate(bullet);
  shot.getComponent<TransformComponent>()!.position.setFrom(muzzle);
  return shot;
}

/// Bobs the cannon up and down, and fires five times a second.
class CannonSystem extends System {
  double _time = 0;
  double _cooldown = 0;

  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TransformComponent, TagComponent];

  @override
  void update(double deltaTime) {
    final cannon = world.findTagged('cannon');
    if (cannon == null) return;
    _time += deltaTime;
    final position = cannon.getComponent<TransformComponent>()!.position;
    position.y = sin(_time * 2) * 300;

    _cooldown -= deltaTime;
    if (_cooldown <= 0) {
      _cooldown += 0.2;
      fire(world, position + Vector3(70, 0, 0));
    }
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
    ..addSystem(CannonSystem())
    // The engine's own system for LifetimeComponent; not a default one.
    ..addSystem(LifetimeSystem());

  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-760, 0, 0)),
    Rectangle2DComponent(
      width: 110,
      height: 56,
      cornerRadius: 10,
      fillStyle: const ShapePaintStyle(color: Colors.lightBlue),
    ),
    TagComponent('cannon'),
  ], name: 'Cannon');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
