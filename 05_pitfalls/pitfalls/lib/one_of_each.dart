// Five: one component of each type per entity. Run it with
//
//     flutter run -t lib/one_of_each.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'labels.dart';

const blue = ShapePaintStyle(color: Colors.lightBlue);
const amber = ShapePaintStyle(color: Colors.amber);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;

  // Wrong: a rectangle, then a circle. Both are RenderableComponents, so
  // the circle replaces the rectangle.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-420, 0, 0)),
    Rectangle2DComponent(
      width: 300,
      height: 180,
      cornerRadius: 16,
      fillStyle: blue,
    ),
    Circle2DComponent(radius: 56, fillStyle: amber),
  ], name: 'OneEntity');

  // Right: the second drawing on a child entity.
  final card = world.createEntityWithComponents([
    TransformComponent(position: Vector3(420, 0, 0)),
    Rectangle2DComponent(
      width: 300,
      height: 180,
      cornerRadius: 16,
      fillStyle: blue,
    ),
  ], name: 'Card');
  world.createEntityWithComponents([
    TransformComponent(),
    ParentComponent(parentId: card.id, localPosition: Vector3(0, 0, 0)),
    Circle2DComponent(radius: 56, fillStyle: amber),
    LayerComponent(zOrder: 1), // drawn over its parent
  ], name: 'Badge');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          engine: engine,
          overlay: labelsAt([
            label('one entity', -420, 170, color: const Color(0xFFF5746F)),
            label('a parent and a child', 420, 170, color: Colors.lightBlue),
          ]),
        ),
      ),
    ),
  );
}
