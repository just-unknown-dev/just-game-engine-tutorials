// The project as episode 15 leaves it: level_01 has a door whose Timeline Player holds
// door_open.timeline.json, which slides it 240 up and fires "opened".

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
  testWidgets('level_01: the door timeline opens the door', (tester) async {
    final engine = (await tester.runAsync(GameBoot.boot))!;
    final world = engine.world;
    await tester.runAsync(
      () => SceneLoader.loadAsset(world, SceneAssets.pathFor('level_01')),
    );
    final door = world.findEntityByName('Door')!;
    final player = door.getComponent<TimelinePlayerComponent>()!;
    expect(player.timelinePath, 'assets/timelines/door_open.timeline.json');
    final events = <String>[];
    world.getSystem<TimelineSystem>()!.events.listen((e) => events.add(e.name));

    engine.start();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameWidget(engine: engine)),
      ),
    );
    await seconds(tester, 0.3);
    player.play();
    await seconds(tester, 1.5);
    expect(
      door.getComponent<TransformComponent>()!.position.y,
      closeTo(320 - 240, 0.5),
    );
    expect(events, ['opened']);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(engine.dispose);
  });
}
