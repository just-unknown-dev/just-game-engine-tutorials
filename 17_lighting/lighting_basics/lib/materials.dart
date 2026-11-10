// 2D materials: each ninja drawn through a material file of its own.
// Run it with
//
//     flutter run -t lib/materials.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Changes two materials' values as the game runs, per entity: the
/// dissolve comes and goes, and the flash blinks.
class PulseSystem extends System {
  double _time = 0;

  @override
  List<Type> get requiredComponents => [Material2DComponent];

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    forEach((entity) {
      final material = entity.getComponent<Material2DComponent>()!;
      if (material.material.endsWith('dissolve.material2d.json')) {
        material.set('dissolve.amount', 0.5 - 0.5 * cos(_time * 1.5));
      } else if (material.material.endsWith('flash.material2d.json')) {
        material.set('flash.amount', max(0.0, sin(_time * 6)));
      }
    });
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.rendering.backgroundColor = const Color(0xFF1B1830);
  engine.camera.mainCamera.zoom = 4.5;

  final world = engine.world;
  world.addSystem(PulseSystem());

  // Eight ninjas, two rows of four, each with a material.
  const materials = [
    'outline', 'outline_gold', 'glow', 'wave', //
    'dissolve', 'flash', 'greyscale', 'palette',
  ];
  for (final (i, name) in materials.indexed) {
    world.createEntityWithComponents([
      TransformComponent(
        position: Vector3(-142.5 + (i % 4) * 95, i < 4 ? -55 : 55, 0),
      ),
      SpriteAnimationComponent(
        atlasPath: 'assets/sprites/player.json',
        clip: 'idle',
      ),
      Material2DComponent(material: 'assets/materials/$name.material2d.json'),
    ], name: name);
  }

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
