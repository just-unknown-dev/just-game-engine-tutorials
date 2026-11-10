// A timeline built in code: coins that bob, one asset for all of them.
// Run it with
//
//     flutter run -t lib/coins.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Twelve units up and down, for ever. Relative: wherever each coin is.
final bob = TimelineAsset(
  name: 'coin_bob',
  duration: 1.0,
  wrap: TimelineWrap.pingPong,
  tracks: [
    PropertyTrack(
      component: 'TransformComponent',
      field: 'position',
      channel: 'y',
      mode: PropertyTrackMode.relative,
      curve: KeyCurve(const [
        TimelineKey(
          time: 0,
          value: 0,
          interpolation: KeyInterpolation.eased,
          easing: 'easeInOutSine',
        ),
        TimelineKey(time: 1, value: -12),
      ]),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.rendering.backgroundColor = const Color(0xFF1B1830);
  engine.camera.mainCamera.zoom = 4;

  // Seven coins, each playing the same asset at its own speed.
  for (var i = 0; i < 7; i++) {
    engine.world.createEntityWithComponents([
      TransformComponent(position: Vector3(-150.0 + i * 50, 0, 0)),
      SpriteAnimationComponent(
        atlasPath: 'assets/sprites/ninja_coin.json',
        clip: 'spin',
      ),
      TimelinePlayerComponent(
        inline: bob,
        playOnStart: true,
        speed: 0.7 + i * 0.1,
      ),
    ], name: 'Coin');
  }

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
