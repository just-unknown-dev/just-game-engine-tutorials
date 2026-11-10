// One: the world updates in fixed steps. Run it with
//
//     flutter run -t lib/steps.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Moves the box round a circle by deltaTime, never by the wall clock,
/// so the time scale and pause apply to it.
class CircleSystem extends System {
  double angle = 0;

  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TransformComponent, TagComponent];

  @override
  void update(double deltaTime) {
    angle += 1.5 * deltaTime; // radians a second, times the step
    final box = world.findTagged('box')!.getComponent<TransformComponent>()!;
    box.position
      ..x = cos(angle) * 320
      ..y = sin(angle) * 320;
    box.angle = angle;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world.addSystem(CircleSystem());
  world.createEntityWithComponents([
    TransformComponent(),
    Rectangle2DComponent(
      width: 120,
      height: 120,
      cornerRadius: 14,
      fillStyle: const ShapePaintStyle(color: Colors.orange),
    ),
    TagComponent('box'),
  ], name: 'Box');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          engine: engine,
          overlay: Director(engine: engine),
        ),
      ),
    ),
  );
}

/// Over the game, every seven seconds: normal speed, a quarter speed from
/// 2 s, paused from 4 s, and back to normal at 5.5 s. A widget keeps
/// running while the engine is paused, which is why a pause menu works.
class Director extends StatefulWidget {
  const Director({super.key, required this.engine});

  final Engine engine;

  @override
  State<Director> createState() => _DirectorState();
}

class _DirectorState extends State<Director>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  String _status = 'timeScale 1.0';

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final engine = widget.engine;
    final t = (elapsed.inMicroseconds / 1e6) % 7;
    final String status;
    if (t < 2) {
      status = 'timeScale 1.0';
    } else if (t < 4) {
      engine.time.timeScale = 0.25;
      status = 'timeScale 0.25';
    } else if (t < 5.5) {
      if (!engine.isPaused) engine.pause();
      status = 'paused';
    } else {
      if (engine.isPaused) engine.resume();
      engine.time.timeScale = 1.0;
      status = 'timeScale 1.0';
    }
    if (status != _status) setState(() => _status = status);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(56),
        child: Text(
          _status,
          style: TextStyle(
            color: _status == 'paused'
                ? const Color(0xFFF5746F)
                : Colors.white70,
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}
