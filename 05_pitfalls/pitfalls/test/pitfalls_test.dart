// Each demo shows what the episode says: the mistake and the fix.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:pitfalls/axes.dart' as axes;
import 'package:pitfalls/one_of_each.dart' as one_of_each;
import 'package:pitfalls/priority.dart' as priority;
import 'package:pitfalls/steps.dart' as steps;
import 'package:pitfalls/turret.dart' as turret;

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

Vector3 pos(Entity e) => e.getComponent<TransformComponent>()!.position;

/// Takes the app down, then disposes its engine (an overlay may tick every frame).
Future<void> finish(WidgetTester tester, Engine engine) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(engine.dispose);
}

void main() {
  testWidgets('1. fixed steps: time scale and pause apply to deltaTime', (
    tester,
  ) async {
    final engine = await run(tester, steps.main);
    final system = engine.world.getSystem<steps.CircleSystem>()!;
    double angleAfter(double s) {
      return system.angle;
    }

    await seconds(tester, 1);
    final a1 = angleAfter(1);
    await seconds(tester, 0.5);
    expect(
      system.angle - a1,
      closeTo(0.75, 0.03),
      reason: '1.5 rad/s at full speed',
    );

    await seconds(tester, 1); // t = 2.5: a quarter speed
    final a2 = system.angle;
    await seconds(tester, 1);
    expect(
      system.angle - a2,
      closeTo(0.375, 0.03),
      reason: 'a quarter of 1.5 rad/s',
    );
    expect(find.text('timeScale 0.25'), findsOneWidget);

    await seconds(tester, 1); // t = 4.5: paused
    expect(engine.isPaused, isTrue);
    final a3 = system.angle;
    await seconds(tester, 0.5);
    expect(system.angle, a3, reason: 'no steps while paused');
    expect(find.text('paused'), findsOneWidget);

    await seconds(tester, 1); // t = 6: running again
    expect(engine.isPaused, isFalse);
    expect(engine.time.timeScale, 1.0);
    await finish(tester, engine);
  });

  testWidgets('2. +Y is down: -Y jumps, +Y pushes into the floor', (
    tester,
  ) async {
    final engine = await run(tester, axes.main);
    final balls = engine.world.entities.where((e) => e.name == 'Ball').toList();
    final wrong = balls.firstWhere((b) => pos(b).x < 0);
    final right = balls.firstWhere((b) => pos(b).x > 0);
    await seconds(tester, 0.45);
    final rest = pos(right).y;
    expect(pos(wrong).y, closeTo(rest, 2), reason: 'both resting on the floor');

    var highest = rest, lowestWrong = pos(wrong).y, highestWrong = pos(wrong).y;
    for (var i = 0; i < 60; i++) {
      await seconds(tester, 1 / 60);
      if (pos(right).y < highest) highest = pos(right).y;
      final w = pos(wrong).y;
      if (w > lowestWrong) lowestWrong = w;
      if (w < highestWrong) highestWrong = w;
    }
    expect(rest - highest, greaterThan(150), reason: 'the -Y ball jumps');
    expect(
      highestWrong,
      greaterThan(rest - 20),
      reason: 'the +Y ball does not leave the floor',
    );
    await finish(tester, engine);
  });

  testWidgets('3. a TransformComponent is a place in the world', (
    tester,
  ) async {
    final engine = await run(tester, turret.main);
    final world = engine.world;
    final topTank = world.findEntityByName('TopTank')!;
    final bottomTank = world.findEntityByName('BottomTank')!;
    final top = world.findEntityByName('TopTurret')!;
    final bottom = world.findEntityByName('BottomTurret')!;
    for (final t in [1.0, 0.5]) {
      await seconds(tester, t);
      expect(pos(topTank).x.abs(), greaterThan(100), reason: 'the tanks drive');
      // Put at (0, -30) in the world: it rides along 230 below its tank.
      expect(pos(top).x, closeTo(pos(topTank).x, 0.5));
      expect(pos(top).y - pos(topTank).y, closeTo(230, 0.5));
      // localPosition (0, -30), bobbing by up to 10: on its tank.
      expect(pos(bottom).x, closeTo(pos(bottomTank).x, 0.5));
      expect(pos(bottomTank).y - pos(bottom).y, inInclusiveRange(19, 41));
    }
    await finish(tester, engine);
  });

  testWidgets('4. priority: the early ring is a step behind', (tester) async {
    final engine = await run(tester, priority.main);
    final world = engine.world;
    await seconds(tester, 1);
    final box = pos(world.findTagged('box')!);
    final early = pos(world.findEntityByName('EarlyRing')!);
    final late = pos(world.findEntityByName('LateRing')!);
    expect(late.distanceTo(box), closeTo(0, 0.01));
    // 1500 units a second, one step of 1/60 s behind.
    expect(early.distanceTo(box), closeTo(25, 0.5));
    await finish(tester, engine);
  });

  testWidgets('5. one component of each type: one drawing per entity', (
    tester,
  ) async {
    final engine = await run(tester, one_of_each.main);
    final world = engine.world;
    final one = world.findEntityByName('OneEntity')!;
    expect(
      one.getComponent<RenderableComponent>(),
      isA<Circle2DComponent>(),
      reason: 'the circle replaced the rectangle',
    );
    expect(
      one.getComponent<Circle2DComponent>(),
      isNull,
      reason: 'shapes are read as RenderableComponent',
    );
    final card = world.findEntityByName('Card')!;
    final badge = world.findEntityByName('Badge')!;
    expect(card.getComponent<RenderableComponent>(), isA<Rectangle2DComponent>());
    expect(badge.getComponent<RenderableComponent>(), isA<Circle2DComponent>());
    await seconds(tester, 0.1);
    expect(
      card.getComponent<ChildrenComponent>()!.childIds,
      contains(badge.id),
    );
    expect(pos(badge).distanceTo(pos(card)), closeTo(0, 0.01));
    await finish(tester, engine);
  });
}
