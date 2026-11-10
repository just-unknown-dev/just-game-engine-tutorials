// Your own component and system. Run it with
//
//     flutter run
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Data: how fast an entity turns, in radians per second.
class SpinComponent extends Component {
  SpinComponent({this.speed = 1.0});

  double speed;
}

/// Logic: turns every entity that has a transform and a spin.
class SpinSystem extends System {
  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TransformComponent, SpinComponent];

  @override
  void update(double deltaTime) {
    forEach((entity) {
      final transform = entity.getComponent<TransformComponent>()!;
      final spin = entity.getComponent<SpinComponent>()!;
      transform.angle += spin.speed * deltaTime;
    });
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world.addSystem(SpinSystem());

  // Three spinners, each with its own speed. A negative speed turns back.
  for (final (x, speed, color) in [
    (-320.0, 1.0, Colors.orange),
    (0.0, 2.0, Colors.lightBlue),
    (320.0, -3.0, Colors.pinkAccent),
  ]) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 0, 0)),
      Rectangle2DComponent(
        width: 160,
        height: 160,
        cornerRadius: 12,
        fillStyle: ShapePaintStyle(color: color),
      ),
      SpinComponent(speed: speed),
    ], name: 'Spinner');
  }

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
