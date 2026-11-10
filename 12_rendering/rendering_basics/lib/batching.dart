// Batching and culling, with the render system's counts. Run it with
//
//     flutter run -t lib/batching.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// What the last frame drew, for the label.
final counts = ValueNotifier('');

/// Turns batching on at 4 s and culling at 8 s, and reads the counts.
class SwitchesSystem extends System {
  double _time = 0;

  @override
  List<Type> get requiredComponents => const [];

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    final render = world.getSystem<RenderSystem>()!;
    render.batchShapes = _time >= 4;
    render.cullOffscreen = _time >= 8;

    final stats = render.stats;
    counts.value =
        'draw calls ${stats['drawCalls']}    '
        'drawn ${stats['renderedObjects']}    '
        'culled ${stats['culledObjects']}';
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
  engine.rendering.backgroundColor = const Color(0xFF101426);

  final world = engine.world;
  world.addSystem(SwitchesSystem());

  // Three thousand small squares and circles, spread over four screens.
  final random = Random(12);
  for (var i = 0; i < 3000; i++) {
    final size = 6 + random.nextDouble() * 14;
    final fill = ShapePaintStyle(color: colors[i % colors.length]);
    world.createEntityWithComponents([
      TransformComponent(
        position: Vector3(
          (random.nextDouble() - 0.5) * 3840,
          (random.nextDouble() - 0.5) * 2160,
          0,
        ),
      ),
      VelocityComponent(
        velocity: Vector3(
          (random.nextDouble() - 0.5) * 60,
          (random.nextDouble() - 0.5) * 60,
          0,
        ),
      ),
      i.isEven
          ? Rectangle2DComponent(width: size, height: size, fillStyle: fill)
          : Circle2DComponent(radius: size / 2, fillStyle: fill),
    ]);
  }

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          engine: engine,
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(40),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              color: const Color(0xDD07070F),
              child: ValueListenableBuilder(
                valueListenable: counts,
                builder: (context, text, _) => Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
