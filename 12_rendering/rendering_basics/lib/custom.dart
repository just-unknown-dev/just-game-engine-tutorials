// Drawing your own things: in the world, as a pass, and on the screen.
// Run it with
//
//     flutter run -t lib/custom.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Draws the world's x and y axes, inside the camera transform.
class AxesPass extends RenderPass {
  final Paint _paint = Paint()
    ..color = const Color(0x66FFFFFF)
    ..strokeWidth = 3;

  // Before ComponentPainterPass, which runs at 100.
  @override
  int get order => 50;

  @override
  void render(Canvas canvas, RenderContext context, RenderPassFilter filter) {
    final view = context.camera?.visibleBounds;
    if (view == null) return;
    canvas
      ..drawLine(Offset(view.left, 0), Offset(view.right, 0), _paint)
      ..drawLine(Offset(0, view.top), Offset(0, view.bottom), _paint);
  }
}

/// Moves the camera round a circle, so the world slides under the screen.
class CircleCameraSystem extends System {
  CircleCameraSystem(this.camera);

  final OutputCamera camera;
  double _time = 0;

  @override
  List<Type> get requiredComponents => const [];

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    camera.lookAt(Offset(cos(_time) * 260, sin(_time) * 160));
  }
}

/// A dial: a ring of ticks, drawn in the entity's own space.
void drawDial(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = const Color(0xFFF5746F)
    ..strokeWidth = 6
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < 24; i++) {
    final a = i * pi / 12;
    final inner = i % 6 == 0 ? 90.0 : 110.0;
    canvas.drawLine(
      Offset(cos(a), sin(a)) * inner,
      Offset(cos(a), sin(a)) * 130,
      paint,
    );
  }
  canvas.drawCircle(Offset.zero, 14, paint);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: EngineConfig(
      // Everything but rendering, which this game sets up itself.
      defaultSystems: DefaultSystems.all.difference({DefaultSystem.rendering}),
    ),
  );
  await engine.initialize();
  engine.rendering.backgroundColor = const Color(0xFF101426);

  final world = engine.world;
  world.addSystem(
    RenderSystem(
      camera: engine.camera.mainCamera,
      statsSink: engine.rendering,
      passes: [ComponentPainterPass(), AxesPass()],
    ),
  );
  // Adds ParallaxRenderSystem; the RenderSystem above is kept.
  registerDefaultSystems(world, engine, include: {DefaultSystem.rendering});
  world.addSystem(CircleCameraSystem(engine.camera.mainCamera));

  // In the world, sorted with everything else: your own drawing.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(320, -160, 0)),
    RenderableComponent(
      renderable: CustomRenderable(
        onRender: drawDial,
        // What culling checks, in the entity's own space.
        boundsOf: () =>
            Rect.fromCircle(center: Offset.zero, radius: 130),
      ),
    ),
  ], name: 'Dial');

  // On the screen, over the world: a crosshair that never moves.
  engine.rendering.overlayHooks.add((canvas, size) {
    final c = size.center(Offset.zero);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;
    canvas
      ..drawLine(c - const Offset(24, 0), c + const Offset(24, 0), paint)
      ..drawLine(c - const Offset(0, 24), c + const Offset(0, 24), paint);
  }, order: 50);

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
