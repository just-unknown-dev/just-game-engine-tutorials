// Deterministic effects: they count ticks, so they play the same on every
// machine. Run it with
//
//     flutter run -t lib/effects.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// A hit: a short shake, then a fade out; and back, so it plays again.
DeterministicEffect hit() => SequenceEffect(
  loop: true,
  children: [
    DelayEffect(durationTicks: 40),
    ShakeEffect(amplitude: 3, durationTicks: 12),
    FadeEffect(to: 0, durationTicks: 30, easing: EasingType.easeInQuad),
    DelayEffect(durationTicks: 30),
    FadeEffect(to: 1, durationTicks: 20),
  ],
);

/// A coin collected: up, bigger and gold, all at once; then back.
DeterministicEffect collect() => SequenceEffect(
  loop: true,
  children: [
    ParallelEffect(
      children: [
        MoveEffect(
          from: Vector3.zero(),
          to: Vector3(0, -20, 0), // up 20, from wherever it is
          durationTicks: 20,
          easing: EasingType.easeOutCubic,
        ),
        ScaleEffect(to: 1.6, durationTicks: 20),
        ColorTintEffect(to: Colors.amber, durationTicks: 10),
      ],
    ),
    DelayEffect(durationTicks: 40),
    ParallelEffect(
      children: [
        MoveEffect(from: Vector3.zero(), to: Vector3(0, 20, 0)),
        ScaleEffect(to: 1),
        ColorTintEffect(to: Colors.white),
      ],
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
  engine.camera.mainCamera.zoom = 3;

  final world = engine.world;
  // Not a default system: add it once. It advances every effect a tick
  // (1/60 s) each update.
  final effects = EffectSystem();
  world.addSystem(effects);

  for (var i = 0; i < 3; i++) {
    final x = -120.0 + i * 120;
    final oni = world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 40, 0)),
      SpriteAnimationComponent(
        atlasPath: 'assets/sprites/ninja_oni_forest.json',
        clip: 'walk',
      ),
    ], name: 'Oni');
    final coin = world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, -40, 0)),
      SpriteAnimationComponent(
        atlasPath: 'assets/sprites/ninja_coin.json',
        clip: 'spin',
      ),
    ], name: 'Coin');
    // Each starts 20 ticks after the one before.
    effects
      ..scheduleEffect(entity: oni, effect: hit(), startTick: i * 20)
      ..scheduleEffect(entity: coin, effect: collect(), startTick: i * 20);
  }

  // A spirit on a curved path: four points, a cubic bezier, round and back.
  final spirit = world.createEntityWithComponents([
    TransformComponent(position: Vector3(-200, -90, 0)),
    Circle2DComponent(
      radius: 6,
      fillStyle: const ShapePaintStyle(color: Color(0xFF54C5F8)),
    ),
  ], name: 'Spirit');
  effects.scheduleEffect(
    entity: spirit,
    effect: PathEffect(
      waypoints: const [
        Offset(0, 0),
        Offset(120, -60),
        Offset(280, 60),
        Offset(400, 0),
      ],
      cubicBezier: true,
      durationTicks: 120,
      easing: EasingType.easeInOutSine,
      loop: true,
    ),
  );

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
