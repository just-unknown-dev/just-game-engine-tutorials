// Images, atlas regions and clips. Run it with
//
//     flutter run
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// The ninja's atlas: Aseprite JSON, with idle, run, jump and fall tags.
const ninja = 'assets/sprites/player.json';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.rendering.backgroundColor = const Color(0xFF1B1830);
  // The art is small: show it four times as big.
  engine.camera.mainCamera.zoom = 4;

  final world = engine.world;

  // A whole image, smoothed when it is scaled up: a still sprite's default.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-150, -55, 0)),
    SpriteComponent(spritePath: 'assets/sprites/ninja_barrel.png'),
  ], name: 'Smooth barrel');

  // The same image as pixel art: scaled pixels stay square.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-50, -55, 0)),
    SpriteComponent(
      spritePath: 'assets/sprites/ninja_barrel.png',
      pixelArt: true,
    ),
  ], name: 'Crisp barrel');

  // One region of the atlas, mirrored and tinted: a statue of the ninja.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(50, -55, 0)),
    SpriteComponent(
      spritePath: '',
      atlasPath: ninja,
      region: 'player 0',
      flipX: true,
      tint: const Color(0xFF8E94A8),
      pixelArt: true,
    ),
  ], name: 'Statue');

  // A clip of another atlas: the coin spins.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(150, -55, 0)),
    SpriteAnimationComponent(
      atlasPath: 'assets/sprites/ninja_coin.json',
      clip: 'spin',
    ),
  ], name: 'Coin');

  // Every clip of the ninja's atlas, each at its authored timing.
  for (final (x, clip) in [
    (-150.0, 'idle'),
    (-50.0, 'run'),
    (50.0, 'jump'),
    (150.0, 'fall'),
  ]) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 50, 0)),
      SpriteAnimationComponent(atlasPath: ninja, clip: clip),
    ], name: 'Ninja $clip');
  }

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
