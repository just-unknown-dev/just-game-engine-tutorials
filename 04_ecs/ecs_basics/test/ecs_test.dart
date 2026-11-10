// The episode's five programs do what it says they do.
import 'dart:math';

import 'package:ecs_basics/bullets.dart' as bullets;
import 'package:ecs_basics/coins.dart' as coins;
import 'package:ecs_basics/main.dart' as spin;
import 'package:ecs_basics/swarm.dart' as swarm;
import 'package:ecs_basics/tank.dart' as tank;
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';

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

void main() {
  testWidgets('spinners: each turns at its own speed', (tester) async {
    final engine = await run(tester, spin.main);
    final spinners = engine.world.entities.where((e) => e.name == 'Spinner').toList();
    expect(spinners, hasLength(3));
    final before = [for (final s in spinners) s.getComponent<TransformComponent>()!.angle];
    await seconds(tester, 1);
    final turned = [
      for (final (i, s) in spinners.indexed) s.getComponent<TransformComponent>()!.angle - before[i],
    ];
    expect(turned[0], closeTo(1, 0.05));
    expect(turned[1], closeTo(2, 0.05));
    expect(turned[2], closeTo(-3, 0.05));
    await tester.runAsync(engine.dispose);
  });

  testWidgets('swarm: one system moves six hundred entities', (tester) async {
    final engine = await run(tester, swarm.main);
    final world = engine.world;
    final orbiting = world.query([TransformComponent, swarm.OrbitComponent]);
    expect(orbiting, hasLength(600));
    expect(find.text('600 entities, one system'), findsOneWidget);
    await seconds(tester, 0.5);
    // Every entity is on its tilted ring.
    for (final e in orbiting) {
      final o = e.getComponent<swarm.OrbitComponent>()!;
      final p = pos(e);
      expect(p.x, closeTo(cos(o.angle) * o.radius, 1e-6));
      expect(p.y, closeTo(sin(o.angle) * o.radius * 0.55, 1e-6));
    }
    await tester.runAsync(engine.dispose);
  });

  testWidgets('coins: the event scores, the command buffer removes', (tester) async {
    coins.score.value = 0;
    final engine = await run(tester, coins.main);
    final world = engine.world;
    expect(world.allTagged('coin'), hasLength(8));
    await seconds(tester, 7);
    expect(world.allTagged('coin'), isEmpty);
    expect(coins.score.value, 80);
    await tester.pump();
    expect(find.text('Score 80'), findsOneWidget);
    await tester.runAsync(engine.dispose);
  });

  testWidgets('bullets: copies of the prefab, each gone after 2.5 s', (tester) async {
    final engine = await run(tester, bullets.main);
    final world = engine.world;
    int count() => world.entities.where((e) => e.name == 'Bullet').length;
    await seconds(tester, 1);
    expect(count(), inInclusiveRange(5, 6));
    await seconds(tester, 4);
    // Five a second, each living 2.5 s: about thirteen in the air.
    expect(count(), inInclusiveRange(12, 14));
    final shots = world.entities.where((e) => e.name == 'Bullet').toList();
    expect(shots.map((s) => s.getComponent<VelocityComponent>()).toSet(), hasLength(shots.length),
        reason: 'each copy has its own components');
    await tester.runAsync(engine.dispose);
  });

  testWidgets('tank: the turret and barrel ride on it, and go with it', (tester) async {
    final engine = await run(tester, tank.main);
    final world = engine.world;
    final body = world.findEntityByName('Tank')!;
    final turret = world.findEntityByName('Turret')!;
    final barrel = world.findEntityByName('Barrel')!;
    expect(body.getComponent<ChildrenComponent>(), isNotNull);

    await seconds(tester, 3);
    expect(pos(turret).distanceTo(pos(body)), closeTo(0, 0.5), reason: 'the turret sits on the tank');
    expect(pos(barrel).distanceTo(pos(turret)), closeTo(70, 0.5), reason: '70 units out from the turret');
    // The barrel points where the turret has turned to, in world space.
    final aim = body.getComponent<TransformComponent>()!.angle +
        turret.getComponent<ParentComponent>()!.localRotation.z;
    final dir = pos(barrel) - pos(turret);
    expect(atan2(dir.y, dir.x), closeTo(atan2(sin(aim), cos(aim)), 0.05));

    await seconds(tester, 11.5); // destroyed 14 s in
    expect(body.isAlive, isFalse);
    expect(turret.isAlive, isFalse);
    expect(barrel.isAlive, isFalse);
    await tester.runAsync(engine.dispose);
  });
}
