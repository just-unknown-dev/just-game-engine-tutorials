// Two shots, a trigger that switches between them, blends, a shake and
// letterbox bars. Run it with
//
//     flutter run -t lib/shots.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'level.dart';
import 'main.dart' show addFollowCam;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world.addSystem(RunnerSystem());
  buildLevel(world);
  addFollowCam(world).getComponent<CameraFramingComponent>()!.lookaheadTime = 0;

  // A wide, fixed shot of the end room, with a hand-held drift. Its trigger
  // raises its priority from 5 to 25 while the player is inside, so it
  // wins there.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(3600, 420, 0)),
    VirtualCameraComponent(priority: 5, zoom: 0.95),
    CameraTriggerComponent(
      width: 800,
      height: 800,
      mode: CameraTriggerMode.boostPriority,
      amount: 20,
    ),
    CameraNoiseComponent(preset: CameraNoisePreset.handheldMild),
    CameraImpulseListenerComponent(),
  ], name: 'RoomCam');

  // Blend over 0.8 s, but cut straight back when leaving the room.
  final brain = engine.camera.brain
    ..defaultBlend = const CameraBlend(duration: 0.8)
    ..blendTable.rules.add(
      const CameraBlendRule(from: 'RoomCam', blend: CameraBlend.cut),
    );

  // Letterbox bars while the room's shot is live.
  final bars = LetterboxEffect();
  engine.camera.mainCamera.effectManager.addEffect(bars);
  brain.onCameraActivated = (from, to) =>
      to.name == 'RoomCam' ? bars.show(0.6) : bars.hide(0.3);

  // Into the room, a stomp that shakes every listening shot, and out again.
  addRunner(
    world,
    2300,
    const [
      (seconds: 1.0, speed: 0, hop: false),
      (seconds: 3.4, speed: 380, hop: false),
      (seconds: 1.0, speed: 0, hop: false),
      (seconds: 1.6, speed: 0, hop: true),
      (seconds: 2.6, speed: -500, hop: false),
      (seconds: 1.4, speed: 0, hop: false),
    ],
    onLand: (runner) {
      final at = runner.getComponent<TransformComponent>()!.position;
      brain.emitImpulse(
        CameraImpulse(
          position: Offset(at.x, at.y),
          amplitude: 22,
          duration: 0.5,
        ),
      );
    },
  );

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
