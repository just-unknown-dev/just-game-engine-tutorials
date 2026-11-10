// The whole of level 1, standing still, with its spawn points marked. Run
// it with
//
//     flutter run -t lib/overview.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'spawners.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  await SceneLoader.loadAsset(world, SceneAssets.pathFor('level_01'));

  // A ring on every spawn point: white for the player, coral for enemies.
  for (final (spawner, color) in [
    ('player', Colors.white),
    ('enemy', const Color(0xFFF5746F)),
  ]) {
    for (final point in SpawnPoints.of(world, spawner)) {
      point.addComponent(
        Circle2DComponent(
          radius: 44,
          filled: false,
          strokeWidth: 6,
          strokeStyle: ShapePaintStyle(color: color),
        ),
      );
    }
  }
  SpawnPoints.spawnAll(world, spawners);

  // Switch the scene's camera off, and look at the whole level.
  world.findEntityByName('MainCamera')!.isActive = false;
  engine.camera.mainCamera
    ..lookAt(const Offset(1000, 60))
    ..zoom = 0.55;

  engine.start();
  engine.pause(); // standing still
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
