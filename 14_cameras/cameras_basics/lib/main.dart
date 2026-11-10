// A virtual camera that follows the player, framed and kept inside the
// level. Run it with
//
//     flutter run
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'level.dart';

/// A shot that follows whoever is tagged "player".
Entity addFollowCam(World world) => world.createEntityWithComponents([
  TransformComponent(),
  VirtualCameraComponent(follow: const EntityTarget.tag('player'), zoom: 1.4),
  CameraFramingComponent(
    screenY: 0.15, // the player sits a little below the middle
    deadZoneWidth: 0.15,
    deadZoneHeight: 0.25,
    dampingX: 0.3,
    lookaheadTime: 0.25,
  ),
  // The view never shows anything outside the LevelBounds rectangle.
  CameraConfinerComponent(boundsName: 'LevelBounds'),
], name: 'FollowCam');

/// Draws a shot's framing on the screen: the dead zone, where the player
/// moves without the camera, and the soft zone it never leaves.
void showFraming(Engine engine, CameraFramingComponent framing) {
  final dead = Paint()..color = const Color(0x40F5746F);
  final soft = Paint()
    ..color = const Color(0x80FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  engine.rendering.overlayHooks.add((canvas, size) {
    final middle = Offset(
      size.width * (0.5 + framing.screenX),
      size.height * (0.5 + framing.screenY),
    );
    Rect zone(double w, double h) => Rect.fromCenter(
      center: middle,
      width: size.width * w,
      height: size.height * h,
    );
    canvas
      ..drawRect(zone(framing.softZoneWidth, framing.softZoneHeight), soft)
      ..drawRect(zone(framing.deadZoneWidth, framing.deadZoneHeight), dead);
  }, order: 50);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world.addSystem(RunnerSystem());
  buildLevel(world);

  // Right along the level, a hop, a stop, then fast back to the start.
  addRunner(world, 300, const [
    (seconds: 1.0, speed: 0, hop: false),
    (seconds: 2.0, speed: 520, hop: false),
    (seconds: 1.2, speed: 520, hop: true),
    (seconds: 1.0, speed: 0, hop: false),
    (seconds: 3.6, speed: 520, hop: false),
    (seconds: 1.2, speed: 0, hop: false),
    (seconds: 4.9, speed: -720, hop: false),
    (seconds: 1.1, speed: 0, hop: false),
  ]);

  final camera = addFollowCam(world);
  showFraming(engine, camera.getComponent<CameraFramingComponent>()!);

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
