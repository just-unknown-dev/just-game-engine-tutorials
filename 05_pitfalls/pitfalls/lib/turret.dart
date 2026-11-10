// Three: TransformComponent is the world transform. Run it with
//
//     flutter run -t lib/turret.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'labels.dart';

/// Hangs a turret on [tank], 30 units above its centre. From the next
/// update on it moves and turns with the tank.
Entity addTurret(World world, Entity tank, String name) =>
    world.createEntityWithComponents([
      TransformComponent(),
      // Where the turret sits in the tank's space. The next update places
      // it there, whatever its TransformComponent says now.
      ParentComponent(parentId: tank.id, localPosition: Vector3(0, -30, 0)),
      Rectangle2DComponent(width: 50, height: 12),
    ], name: name);

/// The mistake: a TransformComponent is a place in the world, so this
/// puts the turret at (0, -30) in the world. With no local values, its
/// offset from the tank is worked out from there, and it rides along
/// that far away.
Entity addTurretWrong(World world, Entity tank, String name) =>
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(0, -30, 0)),
      ParentComponent(parentId: tank.id),
      Rectangle2DComponent(width: 50, height: 12),
    ], name: name);

/// Drives both tanks back and forth, and bobs the right turret on its tank.
class TankSystem extends System {
  double _time = 0;

  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TransformComponent, TagComponent];

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    for (final tank in world.allTagged('tank')) {
      tank.getComponent<TransformComponent>()!.position.x = sin(_time) * 500;
    }
    // To move a turret on its tank, change its localPosition.
    final turret = world.findEntityByName('BottomTurret')!;
    turret.getComponent<ParentComponent>()!.localPosition.y =
        -30 - 10 * sin(_time * 4);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world.addSystem(TankSystem());
  Entity tank(String name, double y) => world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, y, 0)),
    Rectangle2DComponent(
      width: 120,
      height: 48,
      cornerRadius: 10,
      fillStyle: const ShapePaintStyle(color: Color(0xFF6B8F4E)),
    ),
    TagComponent('tank'),
  ], name: name);
  addTurretWrong(world, tank('TopTank', -260), 'TopTurret');
  addTurret(world, tank('BottomTank', 300), 'BottomTurret');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          engine: engine,
          overlay: labelsAt([
            label(
              'TransformComponent: (0, -30)',
              0,
              -380,
              color: const Color(0xFFF5746F),
            ),
            label(
              'ParentComponent localPosition: (0, -30)',
              0,
              400,
              color: Colors.lightBlue,
            ),
          ]),
        ),
      ),
    ),
  );
}
