// One system, six hundred entities. Run it with
//
//     flutter run -t lib/swarm.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Where an entity circles the centre, and how fast.
class OrbitComponent extends Component {
  OrbitComponent({required this.radius, required this.speed, this.angle = 0});

  double radius;
  double speed; // radians per second
  double angle;
}

/// Moves every entity that orbits: all six hundred, in one loop.
class OrbitSystem extends System {
  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TransformComponent, OrbitComponent];

  @override
  void update(double deltaTime) {
    forEach((entity) {
      final orbit = entity.getComponent<OrbitComponent>()!;
      orbit.angle += orbit.speed * deltaTime;
      entity.getComponent<TransformComponent>()!.position
        ..x = cos(orbit.angle) * orbit.radius
        ..y = sin(orbit.angle) * orbit.radius * 0.55; // a tilted ring
    });
  }
}

const colors = [
  Color(0xFFF5746F),
  Colors.orange,
  Colors.lightBlue,
  Colors.white70,
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world.addSystem(OrbitSystem());

  final random = Random(4);
  for (var i = 0; i < 600; i++) {
    final radius = 80 + random.nextDouble() * 760;
    world.createEntityWithComponents([
      TransformComponent(),
      Circle2DComponent(
        radius: 2 + random.nextDouble() * 6,
        fillStyle: ShapePaintStyle(color: colors[i % colors.length]),
      ),
      OrbitComponent(
        radius: radius,
        speed: 90 / radius, // the inner ones go round faster
        angle: random.nextDouble() * 2 * pi,
      ),
    ]);
  }

  // A query: every entity that has both components.
  final orbiting = world.query([TransformComponent, OrbitComponent]);

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          engine: engine,
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Text(
                '${orbiting.length} entities, one system',
                style: const TextStyle(color: Colors.white70, fontSize: 30),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
