// The episode's six programs do what it says they do.
// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:rendering_basics/batching.dart' as batching;
import 'package:rendering_basics/custom.dart' as custom;
import 'package:rendering_basics/layers.dart' as layers;
import 'package:rendering_basics/main.dart' as shapes;
import 'package:rendering_basics/parallax.dart' as parallax;
import 'package:rendering_basics/topdown.dart' as topdown;

Future<Engine> run(WidgetTester tester, Future<void> Function() main) async {
  await tester.runAsync(main);
  await tester.pump();
  return tester.widget<GameWidget>(find.byType(GameWidget)).engine;
}

Future<void> seconds(WidgetTester tester, double s) async {
  for (var i = 0; i < (s * 60).round(); i++) {
    await tester.pump(const Duration(microseconds: 1000000 ~/ 60));
  }
}

/// The names of what the render system draws, in order.
List<String?> drawOrder(Engine engine) => [
  for (final (entity, _)
      in engine.world.getSystem<RenderSystem>()!.debugDrawOrder())
    entity.name,
];

void main() {
  testWidgets(
    'shapes: five, all stored as RenderableComponent, changed as they run',
    (tester) async {
      final engine = await run(tester, shapes.main);
      final world = engine.world;
      Entity named(String name) => world.findEntityByName(name)!;
      expect(
        named('Rectangle').getComponent<RenderableComponent>(),
        isA<Rectangle2DComponent>(),
      );
      expect(
        named('Circle').getComponent<RenderableComponent>(),
        isA<Circle2DComponent>(),
      );
      expect(
        named('Capsule').getComponent<RenderableComponent>(),
        isA<Capsule2DComponent>(),
      );
      expect(
        named('Polygon').getComponent<RenderableComponent>(),
        isA<Polygon2DComponent>(),
      );
      expect(
        named('Line').getComponent<RenderableComponent>(),
        isA<Line2DComponent>(),
      );
      // Asked for by its own type, a shape isn't found.
      expect(named('Circle').getComponent<Circle2DComponent>(), isNull);

      final circle =
          named('Circle').getComponent<RenderableComponent>()!
              as Circle2DComponent;
      final corners =
          named('Rectangle').getComponent<RenderableComponent>()!
              as Rectangle2DComponent;
      await seconds(tester, 0.75); // a quarter turn of the wave: sin(1.5) ≈ 1
      expect(circle.radius, closeTo(116, 0.5));
      expect(corners.cornerRadius, closeTo(100, 0.5));
      await tester.runAsync(engine.dispose);
    },
  );

  testWidgets('layers: drawn by layer, then zOrder, not in the order made', (
    tester,
  ) async {
    final engine = await run(tester, layers.main);
    expect(drawOrder(engine), [
      'Sky',
      'Hills',
      'Ground',
      'Tree',
      'Tree',
      'Hero',
      'Front tree',
      'Bush',
    ]);
    expect(
      engine.world.entities.first.name,
      'Bush',
      reason: 'the bush is made first',
    );
    await tester.runAsync(engine.dispose);
  });

  testWidgets('topdown: lower on screen is drawn in front', (tester) async {
    final engine = await run(tester, topdown.main);
    for (final t in [0.0, 1.0, 2.5, 4.0]) {
      await seconds(tester, t == 0 ? 0 : 1.2);
      final order = engine.world
          .getSystem<RenderSystem>()!
          .debugDrawOrder()
          .map((e) => e.$1)
          .toList();
      final ys = [
        for (final e in order) e.getComponent<TransformComponent>()!.position.y,
      ];
      expect(
        ys,
        orderedEquals([...ys]..sort()),
        reason: 'sorted by y at ${t}s',
      );
    }
    await tester.runAsync(engine.dispose);
  });

  testWidgets('batching: fewer draw calls, then fewer drawn', (tester) async {
    final engine = await run(tester, batching.main);
    Map<String, int> stats() => engine.world.getSystem<RenderSystem>()!.stats;
    await seconds(tester, 2);
    expect(stats()['drawCalls'], 3000);
    expect(stats()['renderedObjects'], 3000);
    await seconds(tester, 3);
    expect(stats()['drawCalls'], lessThan(10));
    expect(stats()['renderedObjects'], 3000);
    await seconds(tester, 4);
    expect(stats()['culledObjects'], greaterThan(1500));
    expect(stats()['renderedObjects']! + stats()['culledObjects']!, 3000);
    expect(batching.counts.value, startsWith('draw calls '));
    await tester.runAsync(engine.dispose);
  });

  testWidgets('custom: its own render system, a pass and a screen hook', (
    tester,
  ) async {
    final engine = await run(tester, custom.main);
    final render = engine.world.getSystem<RenderSystem>()!;
    expect(render.passes.map((p) => p.runtimeType), [
      custom.AxesPass,
      ComponentPainterPass,
    ]);
    expect(engine.world.getSystem<ParallaxRenderSystem>(), isNotNull);
    expect(engine.rendering.overlayHooks.isEmpty, isFalse);
    final camera = engine.camera.mainCamera;
    final before = camera.position;
    await seconds(tester, 1);
    expect(
      (camera.position - before).distance,
      greaterThan(50),
      reason: 'the camera moves',
    );
    await tester.runAsync(engine.dispose);
  });

  testWidgets('parallax: four layers, and the camera on the hero', (
    tester,
  ) async {
    final engine = await run(tester, parallax.main);
    final background = engine.world
        .findEntityByName('Background')!
        .getComponent<ParallaxComponent>()!
        .background;
    expect(background.layers.map((l) => l.scrollFactorX), [0, 0.05, 0.15, 0.4]);
    final hero = engine.world.findEntityByName('Hero')!;
    await seconds(tester, 2);
    final x = hero.getComponent<TransformComponent>()!.position.x;
    expect(x, closeTo(640, 10));
    expect(engine.camera.mainCamera.position.dx, closeTo(x, 10));
    await tester.runAsync(engine.dispose);
  });
}
