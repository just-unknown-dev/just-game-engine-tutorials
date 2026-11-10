// A parallax background behind a scrolling world. Run it with
//
//     flutter run -t lib/parallax.dart
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Keeps the camera on the hero.
class FollowSystem extends System {
  FollowSystem(this.camera, this.hero);

  final OutputCamera camera;
  final Entity hero;

  @override
  List<Type> get requiredComponents => const [];

  @override
  void update(double deltaTime) {
    final position = hero.getComponent<TransformComponent>()!.position;
    camera.lookAt(Offset(position.x, 0));
  }
}

Future<void> addBackground(Engine engine) async {
  Future<ui.Image> load(String name) async =>
      (await engine.assets.loadImage('assets/backgrounds/$name.png')).image!;

  engine.world.createEntityWithComponents([
    ParallaxComponent(
      background: ParallaxBackground(
        // Back to front. 0 stays put, like a sky; 1 moves with the world.
        layers: [
          ParallaxLayer.uniform(image: await load('sky'), scrollFactor: 0),
          ParallaxLayer(
            image: await load('clouds'),
            scrollFactorX: 0.05,
            velocityX: 12, // drifts on its own, in pixels a second
          ),
          ParallaxLayer(image: await load('mountains'), scrollFactorX: 0.15),
          ParallaxLayer(image: await load('hills'), scrollFactorX: 0.4),
        ],
      ),
    ),
  ], name: 'Background');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  await addBackground(engine);

  final world = engine.world;

  // The world: a long strip of ground, and trees along it.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(10000, 472, 0)),
    Rectangle2DComponent(
      width: 22000,
      height: 160,
      fillStyle: const ShapePaintStyle(color: Color(0xFF0B0816)),
      strokeStyle: const ShapePaintStyle(color: Colors.transparent),
    ),
  ], name: 'Ground');

  final random = Random(3);
  for (var x = -1200.0; x < 20000; x += 220 + random.nextDouble() * 260) {
    final height = 150 + random.nextDouble() * 170;
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 392, 0)),
      Polygon2DComponent(
        vertices: [
          Offset(0, -height),
          Offset(height * 0.28, 0),
          Offset(-height * 0.28, 0),
        ],
        fillStyle: const ShapePaintStyle(color: Color(0xFF0B0816)),
        strokeStyle: const ShapePaintStyle(color: Colors.transparent),
      ),
    ], name: 'Tree');
  }

  final hero = world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 330, 0)),
    VelocityComponent(velocity: Vector3(320, 0, 0)),
    Capsule2DComponent(
      width: 56,
      height: 124,
      fillStyle: const ShapePaintStyle(color: Color(0xFFF5746F)),
    ),
    LayerComponent(zOrder: 10),
  ], name: 'Hero');
  world.addSystem(FollowSystem(engine.camera.mainCamera, hero));

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
