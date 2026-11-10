// Draw order: layers, then zOrder. Run it with
//
//     flutter run -t lib/layers.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

const noOutline = ShapePaintStyle(color: Colors.transparent);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  final world = engine.world;

  // In front of everything, though it is made first: a bush.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(140, 330, 0)),
    Circle2DComponent(
      radius: 110,
      fillStyle: const ShapePaintStyle(color: Color(0xFF0B2A1E)),
      strokeStyle: noOutline,
    ),
    LayerComponent(layer: LevelLayers.foreground),
  ], name: 'Bush');

  // Far behind: the sky, then the far hills.
  world.createEntityWithComponents([
    TransformComponent(),
    Rectangle2DComponent(
      width: 1920,
      height: 1080,
      fillStyle: const ShapePaintStyle(
        gradient: ShapeGradient.linear(
          colors: [Color(0xFF14213D), Color(0xFF5B7DB1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      strokeStyle: noOutline,
    ),
    LayerComponent(layer: LevelLayers.background),
  ], name: 'Sky');

  world.createEntityWithComponents([
    TransformComponent(),
    Polygon2DComponent(
      vertices: [
        const Offset(-1000, 540),
        for (var x = -1000.0; x <= 1000; x += 20)
          Offset(x, 110 + 50 * sin(x / 160) + 25 * sin(x / 55)),
        const Offset(1000, 540),
      ],
      fillStyle: const ShapePaintStyle(color: Color(0xFF26355A)),
      strokeStyle: noOutline,
    ),
    LayerComponent(layer: LevelLayers.backgroundNear),
  ], name: 'Hills');

  // The main layer. The ground and the trees have no LayerComponent:
  // a shape's own layer and zOrder are 0.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 420, 0)),
    Rectangle2DComponent(
      width: 1920,
      height: 240,
      fillStyle: const ShapePaintStyle(color: Color(0xFF1C4A33)),
      strokeStyle: noOutline,
    ),
  ], name: 'Ground');

  for (final x in [-560.0, -100.0]) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 300, 0)),
      tree(),
    ], name: 'Tree');
  }

  // The hero: zOrder 10, in front of the trees.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-1050, 225, 0)),
    VelocityComponent(velocity: Vector3(260, 0, 0)),
    Capsule2DComponent(
      width: 70,
      height: 150,
      fillStyle: const ShapePaintStyle(color: Color(0xFFF5746F)),
    ),
    LayerComponent(zOrder: 10),
  ], name: 'Hero');

  // zOrder 20: this tree is in front of the hero.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(560, 300, 0)),
    tree(),
    LayerComponent(zOrder: 20),
  ], name: 'Front tree');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}

/// A tree: a triangle standing on the entity's position.
Polygon2DComponent tree() => Polygon2DComponent(
  vertices: const [Offset(0, -330), Offset(95, 0), Offset(-95, 0)],
  fillStyle: const ShapePaintStyle(color: Color(0xFF2E7D4F)),
  strokeStyle: noOutline,
);
