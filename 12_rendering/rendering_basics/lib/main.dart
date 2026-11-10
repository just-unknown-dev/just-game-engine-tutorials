// The five shapes that draw themselves. Run it with
//
//     flutter run
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Changes the shapes every step. Every field is read when a shape draws,
/// so the next frame shows the change.
class BreatheSystem extends System {
  double _time = 0;

  @override
  List<Type> get requiredComponents => [RenderableComponent];

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    final wave = sin(_time * 2); // -1 … 1
    forEach((entity) {
      // Shapes are stored as RenderableComponent: ask for that, then check.
      final shape = entity.getComponent<RenderableComponent>();
      if (shape is Rectangle2DComponent) shape.cornerRadius = 50 + 50 * wave;
      if (shape is Circle2DComponent) shape.radius = 100 + 16 * wave;
      if (shape is Line2DComponent) shape.end = Offset(90, -90 * wave);
    });
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.rendering.backgroundColor = const Color(0xFF101426);

  final world = engine.world;
  world.addSystem(BreatheSystem());

  // A rectangle with round corners and a gradient, left to right.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-640, 0, 0)),
    Rectangle2DComponent(
      width: 200,
      height: 200,
      cornerRadius: 24,
      fillStyle: const ShapePaintStyle(
        gradient: ShapeGradient.linear(
          colors: [Color(0xFFF5746F), Colors.orange],
        ),
      ),
    ),
  ], name: 'Rectangle');

  // A circle: a radial gradient, and no outline.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-320, 0, 0)),
    Circle2DComponent(
      radius: 100,
      fillStyle: const ShapePaintStyle(
        gradient: ShapeGradient.radial(
          colors: [Colors.white, Colors.lightBlue],
        ),
      ),
      strokeStyle: const ShapePaintStyle(color: Colors.transparent),
    ),
  ], name: 'Circle');

  // A capsule: round at both ends of its longer side.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 0, 0)),
    Capsule2DComponent(
      width: 110,
      height: 230,
      fillStyle: const ShapePaintStyle(color: Colors.teal),
    ),
  ], name: 'Capsule');

  // A polygon: points around the entity, closed back to the first.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(320, 0, 0)),
    Polygon2DComponent(
      vertices: [
        for (var i = 0; i < 6; i++)
          Offset(cos(i * pi / 3) * 115, sin(i * pi / 3) * 115),
      ],
      fillStyle: const ShapePaintStyle(
        gradient: ShapeGradient.sweep(
          colors: [Colors.amber, Colors.pinkAccent, Colors.amber],
        ),
      ),
      strokeStyle: const ShapePaintStyle(color: Colors.white),
      strokeWidth: 4,
    ),
  ], name: 'Polygon');

  // A line from `start` to `end`, around the entity, with round caps.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(640, 0, 0)),
    Line2DComponent(
      start: const Offset(-90, 90),
      end: const Offset(90, -90),
      strokeStyle: const ShapePaintStyle(color: Colors.pinkAccent),
      strokeWidth: 16,
      roundCaps: true,
    ),
  ], name: 'Line');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
