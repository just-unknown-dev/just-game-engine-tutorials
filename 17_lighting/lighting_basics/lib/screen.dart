// Screen materials: the whole view drawn through a material, here over the
// lit cave. Run it with
//
//     flutter run -t lib/screen.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'main.dart' show caveScene;

/// Shows each screen material in turn, three seconds each.
class ScreenCycleSystem extends System {
  ScreenCycleSystem(this.screen);

  final ScreenMaterialComponent screen;
  double _time = 0;

  static const materials = ['pixelate', 'crt', 'grade'];

  @override
  List<Type> get requiredComponents => const [];

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    final name = materials[(_time ~/ 3) % materials.length];
    screen.material = 'assets/materials/$name.material2d.json';
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = await caveScene();

  // On an entity of its own: the highest order wins when there are several.
  final screen = ScreenMaterialComponent(
    material: 'assets/materials/pixelate.material2d.json',
  );
  engine.world.createEntityWithComponents([screen], name: 'Screen');
  engine.world.addSystem(ScreenCycleSystem(screen));

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
