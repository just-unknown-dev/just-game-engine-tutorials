import 'package:flutter/foundation.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Loads [name], or the first scene in scenes.json, into the world.
Future<void> startLevel(
  Engine engine,
  List<Spawner> spawners, {
  String? name,
}) async {
  final world = engine.world;
  final scene = name ?? (await SceneLoader.loadManifest()).first;
  await SceneLoader.loadAsset(world, SceneAssets.pathFor(scene));

  // Maps and their tile collision, before the first frame: otherwise the
  // player can fall through ground that is still loading.
  await LevelMaps.preload(world);

  // Spawn points name what to create; the game says how.
  SpawnPoints.spawnAll(
    world,
    spawners,
    onMissing: (point, id) => debugPrint('No spawner for "$id"'),
  );
}

/// Replaces the current level with [name].
Future<void> changeLevel(
  Engine engine,
  List<Spawner> spawners,
  String name,
) async {
  engine.world.destroyAllEntities();
  engine.camera.brain.reset(); // forget the old level's cameras
  await startLevel(engine, spawners, name: name);
  LevelMaps.evictUnused(engine.world); // drop tilesets no map uses now
}

/// Loads [name], or says why it could not.
Future<bool> tryLoad(World world, String name) async {
  try {
    await SceneLoader.loadAsset(world, SceneAssets.pathFor(name));
    return true;
  } on UnknownComponentTypeException catch (e) {
    debugPrint('No definition for ${e.type} (entity ${e.entityName})');
  } on UnsupportedFormatVersionException catch (e) {
    debugPrint('Saved by a newer engine: ${e.found} > ${e.supported}');
  } on FormatException catch (e) {
    debugPrint('Broken scene: ${e.message}');
  }
  return false;
}
