// Top-down draw order: whatever stands lower on screen is in front. Run it with
//
//     flutter run -t lib/topdown.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Walks the walkers up and down, turning at the edges.
class PaceSystem extends System {
  @override
  List<Type> get requiredComponents => [TransformComponent, VelocityComponent];

  @override
  void update(double deltaTime) {
    forEach((entity) {
      final y = entity.getComponent<TransformComponent>()!.position.y;
      final velocity = entity.getComponent<VelocityComponent>()!.velocity;
      if ((y > 300 && velocity.y > 0) || (y < -300 && velocity.y < 0)) {
        velocity.y = -velocity.y;
      }
    });
  }
}

/// Something standing up, sorted by its world y within its layer.
Capsule2DComponent standing(Color color, double width) => Capsule2DComponent(
  width: width,
  height: 130,
  fillStyle: ShapePaintStyle(color: color),
  strokeStyle: const ShapePaintStyle(color: Color(0xFF15301F)),
  strokeWidth: 4,
)..renderable.ySort = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.rendering.backgroundColor = const Color(0xFF3C7A4B);

  final world = engine.world;
  world.addSystem(PaceSystem());

  // A row of stone pillars that never move.
  for (final x in [-600.0, -300.0, 0.0, 300.0, 600.0]) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 0, 0)),
      standing(const Color(0xFFB8BFCC), 90),
    ], name: 'Pillar');
  }

  // Walkers pacing past them, each at its own speed.
  for (final (x, y, speed, color) in [
    (-560.0, -280.0, 150.0, const Color(0xFFF5746F)),
    (-260.0, 120.0, -190.0, Colors.amber),
    (40.0, -60.0, 130.0, Colors.lightBlue),
    (340.0, 260.0, -170.0, Colors.pinkAccent),
    (640.0, -200.0, 210.0, Colors.white),
  ]) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, y, 0)),
      VelocityComponent(velocity: Vector3(0, speed, 0)),
      standing(color, 60),
    ], name: 'Walker');
  }

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
