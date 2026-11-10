// One shot that keeps two players in view, zooming out as they spread.
// Run it with
//
//     flutter run -t lib/group.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'level.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world.addSystem(RunnerSystem());
  buildLevel(world);

  // The group sits at the weighted middle of its members: one member,
  // tagged "player", covers every player.
  world.createEntityWithComponents([
    TransformComponent(),
    CameraTargetGroupComponent(
      members: [
        CameraGroupMember(target: const EntityTarget.tag('player'), radius: 80),
      ],
    ),
  ], name: 'Players');

  // The shot follows the group, and zooms out to keep all of it in view.
  world.createEntityWithComponents([
    TransformComponent(),
    VirtualCameraComponent(follow: const EntityTarget.name('Players')),
    CameraFramingComponent(screenY: 0.15),
    CameraGroupFramingComponent(padding: 0.3, minZoom: 0.5, maxZoom: 1.5),
    CameraConfinerComponent(boundsName: 'LevelBounds'),
  ], name: 'GroupCam');

  // Two players, running apart and back together.
  addRunner(world, 1900, const [
    (seconds: 1.0, speed: 0, hop: false),
    (seconds: 2.0, speed: -460, hop: false),
    (seconds: 1.4, speed: 0, hop: true),
    (seconds: 2.0, speed: 460, hop: false),
    (seconds: 1.6, speed: 0, hop: false),
  ], name: 'Player 1');
  addRunner(
    world,
    2100,
    const [
      (seconds: 1.6, speed: 0, hop: false),
      (seconds: 2.0, speed: 460, hop: true),
      (seconds: 1.4, speed: 0, hop: false),
      (seconds: 2.0, speed: -460, hop: false),
      (seconds: 1.0, speed: 0, hop: false),
    ],
    color: const Color(0xFF54C5F8),
    name: 'Player 2',
  );

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
