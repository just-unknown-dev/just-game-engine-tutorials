// The project as episode 10 leaves it: the Spinner is registered on every engine the game makes, the
// three spinners placed in the Level Designer are saved in level_02, and they turn when the game runs.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:my_game/game/game_boot.dart';
import 'package:my_game/game/spinner.dart';

/// Frames at 60 a second, with real time between them for asset loads.
Future<void> seconds(WidgetTester tester, double s) async {
  for (var i = 0; i < (s * 60).round(); i++) {
    await tester.pump(const Duration(microseconds: 1000000 ~/ 60));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 1)));
  }
}

void main() {
  testWidgets('the Spinner is registered, saved in level_02, and turns', (tester) async {
    final engine = (await tester.runAsync(GameBoot.boot))!;
    final definition = engine.context.definitions.definitionByType('SpinnerComponent');
    expect(definition, isNotNull, reason: 'GameBoot.extensions installs MyGameExtension');
    expect(definition!.fields.map((f) => f.name), ['speed', 'clockwise']);

    final world = engine.world;
    await tester.runAsync(() => SceneLoader.loadAsset(world, SceneAssets.pathFor('level_02')));
    await tester.runAsync(() => LevelMaps.preload(world));
    final spinners = world.query([SpinnerComponent]).toList();
    expect(spinners, hasLength(3), reason: 'the three placed in the Level Designer');
    double speedOf(Entity e) => e.getComponent<SpinnerComponent>()!.speed;
    double angleOf(Entity e) => e.getComponent<TransformComponent>()!.angle;
    expect(spinners.map(speedOf).reduce(math.max), greaterThan(90), reason: 'one was made faster');

    final before = {for (final e in spinners) e: angleOf(e)};
    engine.start();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: GameWidget(engine: engine))));
    await seconds(tester, 1);
    for (final e in spinners) {
      // Clockwise, at its speed, for about a second.
      expect(angleOf(e) - before[e]!, closeTo(speedOf(e) * math.pi / 180, 0.15));
    }

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(engine.dispose);
  });
}
