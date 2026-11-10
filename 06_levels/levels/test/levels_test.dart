// The levels load from their scene files, the spawn points are filled by
// the spawners, the camera follows the player, the goal loads the next
// level, and a scene that can't load says why.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:levels/level.dart';
import 'package:levels/main.dart' as app;
import 'package:levels/overview.dart' as overview;

Future<Engine> run(WidgetTester tester) async {
  await tester.runAsync(app.main);
  await tester.pump();
  return tester.widget<GameWidget>(find.byType(GameWidget)).engine;
}

/// Frames at 60 a second, with real time between them for asset loads.
Future<void> seconds(WidgetTester tester, double s) async {
  for (var i = 0; i < (s * 60).round(); i++) {
    await tester.pump(const Duration(microseconds: 1000000 ~/ 60));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1)),
    );
  }
}

Vector3 pos(Entity e) => e.getComponent<TransformComponent>()!.position;

Future<void> finish(WidgetTester tester, Engine engine) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(engine.dispose);
}

void main() {
  testWidgets('level 1 loads and its spawn points are filled', (tester) async {
    final engine = await run(tester);
    final world = engine.world;
    expect(world.findEntityByName('Ground'), isNotNull);
    expect(
      world
          .findEntityByName('MainCamera')!
          .getComponent<VirtualCameraComponent>(),
      isNotNull,
    );
    expect(SpawnPoints.of(world, 'enemy'), hasLength(3));

    final player = world.findTagged('player')!;
    expect(pos(player).x, -300, reason: 'at the spawn point');
    expect(world.allTagged('enemy'), hasLength(3));

    await seconds(tester, 1.5);
    // On the ground: its top is 300 - 20, the player is 56 tall.
    expect(pos(player).y, closeTo(300 - 20 - 28, 1.5));
    expect(pos(player).x, greaterThan(0), reason: 'running right');
    // The camera brain follows the tag player.
    final camera = engine.camera.mainCamera.position;
    expect((camera.dx - pos(player).x).abs(), lessThan(300));
    await finish(tester, engine);
  });

  testWidgets('the goal loads level 2', (tester) async {
    final engine = await run(tester);
    final world = engine.world;
    await seconds(tester, 10);
    final ground = world.findEntityByName('Ground')!;
    expect(
      ground.getComponent<RenderableComponent>(),
      isA<Rectangle2DComponent>(),
    );
    expect(
      (ground.getComponent<RenderableComponent>()! as Rectangle2DComponent).width,
      2800,
      reason: "level 2's ground",
    );
    expect(world.allTagged('enemy'), hasLength(2));
    expect(world.allTagged('player'), hasLength(1));
    await finish(tester, engine);
  });

  testWidgets('a scene with an unknown component says which', (tester) async {
    final engine = await run(tester);
    final printed = <String>[];
    final before = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message ?? '');
    final count = engine.world.entities.length;
    final ok = (await tester.runAsync(() => tryLoad(engine.world, 'broken')))!;
    debugPrint = before;
    expect(ok, isFalse);
    expect(printed, ['No definition for SpeedBoostComponent (entity Booster)']);
    expect(
      engine.world.entities.length,
      count,
      reason: 'a failed load leaves the world untouched',
    );
    await finish(tester, engine);
  });

  testWidgets('the overview marks the spawn points and frames the level', (
    tester,
  ) async {
    await tester.runAsync(overview.main);
    await tester.pump();
    final engine = tester.widget<GameWidget>(find.byType(GameWidget)).engine;
    final world = engine.world;
    final rings = [
      ...SpawnPoints.of(world, 'player'),
      ...SpawnPoints.of(world, 'enemy'),
    ].where((p) => p.getComponent<RenderableComponent>() is Circle2DComponent);
    expect(rings, hasLength(4));
    expect(world.allTagged('enemy'), hasLength(3));
    await seconds(tester, 0.5);
    expect(engine.camera.mainCamera.zoom, 0.55);
    expect(engine.camera.mainCamera.position.dx, closeTo(1000, 1));
    await finish(tester, engine);
  });
}
