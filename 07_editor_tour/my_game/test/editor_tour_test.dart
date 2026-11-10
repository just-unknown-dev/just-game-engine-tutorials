// The project as episode 07 leaves it: level_02, made with New scene in the editor, is the starter 2D
// scene (a camera, the bounds it keeps to, the player's spawn point), listed after level_01.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:my_game/game/game_boot.dart';

void main() {
  test('scenes.json lists level_01 first, then level_02', () {
    final names = SceneManifest.parse(File(SceneManifest.path).readAsStringSync());
    expect(names, ['level_01', 'level_02']);
  });

  testWidgets('level_02 loads: a camera, its bounds and a spawn point that makes the player', (tester) async {
    final engine = (await tester.runAsync(GameBoot.boot))!;
    final world = engine.world;
    await tester.runAsync(() => SceneLoader.loadAsset(world, SceneAssets.pathFor('level_02')));
    final names = world.entities.map((e) => e.name).toSet();
    expect(names, containsAll(['MainCamera', 'LevelBounds', 'PlayerSpawn']));
    expect(world.query([VirtualCameraComponent]), hasLength(1));

    SpawnPoints.spawnAll(world, GameBoot.spawners);
    final player = world.findTagged('player');
    expect(player, isNotNull, reason: 'the spawn point names the player spawner');
    final spawn = world.findEntityByName('PlayerSpawn')!.getComponent<TransformComponent>()!.position;
    expect(player!.getComponent<TransformComponent>()!.position.x, spawn.x);
    engine.dispose();
  });
}
