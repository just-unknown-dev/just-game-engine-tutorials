// An emitter of your own: flames on wall torches, pushed by forces.
// Run it with
//
//     flutter run -t lib/torch.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// A flame on a torch: a child 40 above it, drawn in front of the level.
Entity addFlame(World world, Entity torch) => world.createEntityWithComponents([
  TransformComponent(),
  ParentComponent(parentId: torch.id, localPosition: Vector3(0, -40, 0)),
  ParticleEmitterComponent(
    emitter: ParticleEmitter(
      maxParticles: 120,
      emissionRate: 60,
      particleLifetime: 0.8,
      startSize: 10,
      endSize: 2,
      startColor: Colors.orange,
      endColor: Colors.red.withValues(alpha: 0),
      emissionAngle: -math.pi / 2, // up is -Y
      emissionSpread: 0.4,
      speed: 90,
      renderer: SquareParticleRenderer(),
      forces: [
        const GravityForce(Offset(0, -60)),
        WindForce(strength: 20, turbulence: 30),
        const DragForce(coefficient: 0.1),
      ],
    ),
  ),
  LayerComponent(layer: LevelLayers.foreground),
], name: 'Flame');

/// A stone wall with three torches on it, each with its own flame.
Future<Engine> torchScene() async {
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.rendering.backgroundColor = const Color(0xFF15112A);
  engine.camera.mainCamera.zoom = 2;

  final world = engine.world;
  world.addSystem(ParticleSystem());

  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 60, 0)),
    Rectangle2DComponent(
      width: 960,
      height: 420,
      fillStyle: const ShapePaintStyle(color: Color(0xFF2B2440)),
      strokeStyle: const ShapePaintStyle(color: Colors.transparent),
    ),
    LayerComponent(layer: LevelLayers.background),
  ], name: 'Wall');
  for (final x in [-280.0, 0.0, 280.0]) {
    final torch = world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 40, 0)),
      Rectangle2DComponent(
        width: 14,
        height: 60,
        cornerRadius: 3,
        fillStyle: const ShapePaintStyle(color: Color(0xFF6B4A35)),
        strokeStyle: const ShapePaintStyle(color: Colors.transparent),
      ),
    ], name: 'Torch');
    addFlame(world, torch);
  }
  return engine;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = await torchScene();
  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
