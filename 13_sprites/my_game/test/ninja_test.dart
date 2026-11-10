// The project as episode 13 leaves it: level_01 has ground and the shrine's sprites, and the player
// spawner makes the ninja, whose animator graph picks its clip from how it moves.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:my_game/game/game_boot.dart';

/// Frames at 60 a second, with real time between them for asset loads.
Future<void> seconds(WidgetTester tester, double s) async {
  for (var i = 0; i < (s * 60).round(); i++) {
    await tester.pump(const Duration(microseconds: 1000000 ~/ 60));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1)),
    );
  }
}

void main() {
  testWidgets('level_01: the ninja lands, and its graph follows it', (
    tester,
  ) async {
    final engine = (await tester.runAsync(GameBoot.boot))!;
    final world = engine.world;
    await tester.runAsync(
      () => SceneLoader.loadAsset(world, SceneAssets.pathFor('level_01')),
    );
    expect(
      world
          .findEntityByName('Torii')!
          .getComponent<SpriteComponent>()!
          .pixelArt,
      isTrue,
    );

    SpawnPoints.spawnAll(world, GameBoot.spawners);
    final ninja = world.findTagged('player')!;
    final animator = ninja.getComponent<AnimatorComponent>()!;
    engine.start();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameWidget(engine: engine)),
      ),
    );
    await seconds(tester, 1.5);
    // The ground's top is at 680; the ninja is 48 tall.
    expect(
      ninja.getComponent<TransformComponent>()!.position.y,
      closeTo(680 - 24, 1.5),
    );
    expect(animator.currentState, 'idle');
    expect(
      animator.getBool('grounded'),
      isTrue,
      reason: 'the binding the game registers',
    );

    final velocity = ninja.getComponent<VelocityComponent>()!.velocity;
    for (var i = 0; i < 30; i++) {
      velocity.x = 240;
      await seconds(tester, 1 / 60);
    }
    expect(animator.currentState, 'move');
    velocity.y = -420;
    await seconds(tester, 0.1);
    expect(animator.currentState, 'jump');
    await seconds(tester, 2);
    expect(
      animator.currentState,
      anyOf('idle', 'move'),
      reason: 'landed again',
    );

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(engine.dispose);
  });
}
