// 2D lighting: ambient light, a point light and a spot light, normal-mapped
// rock, shadow casters and a glowing lantern. Run it with
//
//     flutter run
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Moves the lamp along a figure of eight, so the light sweeps the wall.
class LampSystem extends System {
  LampSystem(this.lamp);

  final Entity lamp;
  double _time = 0;

  @override
  List<Type> get requiredComponents => const [];

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    lamp.getComponent<TransformComponent>()!.position
      ..x = sin(_time * 0.6) * 380
      ..y = sin(_time * 1.2) * 90 - 20;
  }
}

/// The lit cave: its lights, its rock and what casts shadows.
Future<Engine> caveScene() async {
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.camera.mainCamera.zoom = 1.5;

  final world = engine.world;

  // One per scene: turns 2D lighting on, with a dim blue ambient light.
  world.createEntityWithComponents([
    Lighting2DComponent(ambient: const Color(0xFF3A4068), ambientIntensity: 0.55),
  ], name: 'Lighting');

  // A wall of rock, each tile drawn through a material with a normal map.
  for (var row = -3; row <= 3; row++) {
    for (var col = -5; col <= 5; col++) {
      world.createEntityWithComponents([
        TransformComponent(position: Vector3(col * 128.0, row * 128.0, 0)),
        SpriteComponent(spritePath: 'assets/sprites/cave_rock.png'),
        Material2DComponent(material: 'assets/materials/rock.material2d.json'),
        LayerComponent(layer: LevelLayers.background),
      ], name: 'Rock');
    }
  }

  // Things that stop light: a torii gate and two barrels.
  for (final (x, y, image) in [
    (-180.0, 125.0, 'cave_torii'),
    (150.0, 166.0, 'ninja_barrel'),
    (220.0, 166.0, 'ninja_barrel'),
  ]) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, y, 0), scale: Vector3(2, 2, 1)),
      SpriteComponent(spritePath: 'assets/sprites/$image.png', pixelArt: true),
      ShadowCaster2DComponent(),
    ], name: image);
  }

  // A lantern that glows: emissive, so it is bright whatever the light.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(420, 140, 0), scale: Vector3(2, 2, 1)),
    SpriteComponent(
      spritePath: 'assets/sprites/cave_lantern.png',
      pixelArt: true,
    ),
    Material2DComponent(material: 'assets/materials/emissive.material2d.json'),
    Light2DComponent(color: Color(0xFFFFB347), radius: 200, castShadows: false),
  ], name: 'Lantern');

  // A warm point light that moves, and casts shadows.
  final lamp = world.createEntityWithComponents([
    TransformComponent(),
    Light2DComponent(color: const Color(0xFFFFD9A0), intensity: 1.4, radius: 520),
  ], name: 'Lamp');
  world.addSystem(LampSystem(lamp));

  // A cool spot light from the top left, pointing down and to the right.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-560, -300, 0))..angle = pi / 4,
    Light2DComponent(
      kind: Light2DKind.spot,
      color: const Color(0xFF7FB2FF),
      intensity: 1.2,
      radius: 760,
      coneAngle: 40,
    ),
  ], name: 'Spot');
  return engine;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = await caveScene();
  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
