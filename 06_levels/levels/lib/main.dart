// Levels from scene files. Run it with
//
//     flutter run
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'game.dart';
import 'level.dart';
import 'spawners.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.world
    ..addSystem(RunSystem())
    ..addSystem(PatrolSystem())
    ..addSystem(GoalSystem());

  // The levels, in play order, from assets/scenes/scenes.json.
  final scenes = await SceneLoader.loadManifest();
  var current = 0;

  // Reaching the goal loads the next level, after this update.
  engine.world.events.on<GoalReached>((_) {
    current = (current + 1) % scenes.length;
    scheduleMicrotask(() => changeLevel(engine, spawners, scenes[current]));
  });

  // After initialize, before start.
  await startLevel(engine, spawners, name: scenes[current]);

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
