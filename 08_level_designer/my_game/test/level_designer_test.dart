// The project as episode 08 leaves it: level_02, built in the Level Designer and saved, has a Level Map
// whose Ground layer collides, a solid wall placed as a prefab, and a player that drops in at the spawn
// point and lands on the ground stamped there.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:my_game/game/game_boot.dart';

/// Frames at 60 a second, with real time between them for asset loads.
Future<void> seconds(WidgetTester tester, double s) async {
  for (var i = 0; i < (s * 60).round(); i++) {
    await tester.pump(const Duration(microseconds: 1000000 ~/ 60));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 1)));
  }
}

void main() {
  testWidgets('level_02: the map collides and the player lands on it', (tester) async {
    // As lib/game/game_app.dart boots a level.
    final engine = (await tester.runAsync(GameBoot.boot))!;
    final world = engine.world;
    await tester.runAsync(() => SceneLoader.loadAsset(world, SceneAssets.pathFor('level_02')));
    final failures = await tester.runAsync(() => LevelMaps.preload(world));
    expect(failures, isEmpty);

    final map = LevelMaps.primary(world);
    expect(map, isNotNull, reason: 'the Level Map the designer made');
    final ground = map!.layer('Ground');
    expect(ground, isNotNull);
    // Ground under the spawn point (cell 6 of row 14, whose middle is at 208, 464), and the gap erased
    // at cells 12 to 14.
    expect(map.tileAt(ground!, map.cellAt(ground, const Offset(208, 464))), isNotNull);
    expect(map.tileAt(ground, map.cellAt(ground, const Offset(432, 464))), isNull);
    expect(world.entities.where((e) => (e.name ?? '').startsWith('Solid')), isNotEmpty, reason: 'the wall');

    SpawnPoints.spawnAll(world, GameBoot.spawners);
    final player = world.findTagged('player')!;
    engine.start();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: GameWidget(engine: engine))));
    await seconds(tester, 1.5);
    // The ground's top is row 14's top edge, 448; the player is 48 tall.
    expect(player.getComponent<TransformComponent>()!.position.y, closeTo(448 - 24, 1.5));

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(engine.dispose);
  });
}
