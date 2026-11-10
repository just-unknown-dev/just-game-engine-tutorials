// The episode's programs are made of what it says they are. Lit frames draw too slowly under
// `flutter test` to run many of them here, so these step the world without drawing it; the footage
// is filmed from the real app (integration_test/app_capture_test.dart).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:lighting_basics/main.dart' as lighting;
import 'package:lighting_basics/materials.dart' as materials;
import 'package:lighting_basics/screen.dart' as screen;

Map<String, dynamic> material(String name) => jsonDecode(
  File('assets/materials/$name.material2d.json').readAsStringSync(),
) as Map<String, dynamic>;

void main() {
  testWidgets(
    'cave: ambient light, three lights, normal-mapped rock and shadow casters',
    (tester) async {
      final engine = (await tester.runAsync(lighting.caveScene))!;
      final world = engine.world;
      expect(world.query([Lighting2DComponent]), hasLength(1), reason: 'one per scene');
      final lights = {
        for (final e in world.query([Light2DComponent]))
          e.name: e.getComponent<Light2DComponent>()!,
      };
      expect(lights.keys, containsAll(['Lamp', 'Spot', 'Lantern']));
      expect(lights['Spot']!.kind, Light2DKind.spot);
      expect(lights['Lantern']!.castShadows, isFalse);
      expect(world.query([ShadowCaster2DComponent]), hasLength(3));
      final rocks = world.entities.where((e) => e.name == 'Rock').toList();
      expect(rocks, hasLength(77));
      expect(
        rocks.first.getComponent<Material2DComponent>()!.material,
        'assets/materials/rock.material2d.json',
      );
      expect(material('rock')['normalMap'], isA<Map<String, dynamic>>());

      final lamp = world
          .findEntityByName('Lamp')!
          .getComponent<TransformComponent>()!;
      for (var i = 0; i < 60; i++) {
        world.update(1 / 60);
      }
      expect(
        lamp.position.x,
        closeTo(380 * 0.5646, 1),
        reason: 'sin(0.6) of the way along',
      );
      await tester.runAsync(engine.dispose);
    },
  );

  test('materials: a variant names its parent, and the pulse changes values per entity', () {
    expect(
      material('outline_gold')['parent'],
      'assets/materials/outline.material2d.json',
    );
    expect(material('pixelate')['kind'], 'screen');

    final world = World()..addSystem(materials.PulseSystem());
    final dissolve = world.createEntityWithComponents([
      Material2DComponent(material: 'assets/materials/dissolve.material2d.json'),
    ]);
    final flash = world.createEntityWithComponents([
      Material2DComponent(material: 'assets/materials/flash.material2d.json'),
    ]);
    for (var i = 0; i < 60; i++) {
      world.update(1 / 60);
    }
    expect(
      dissolve.getComponent<Material2DComponent>()!['dissolve.amount'] as double,
      closeTo(0.5 - 0.5 * 0.0707, 0.01),
    );
    expect(flash.getComponent<Material2DComponent>()!['flash.amount'], isNotNull);
  });

  test('screen: each screen material for three seconds', () {
    final material = ScreenMaterialComponent();
    final world = World()..addSystem(screen.ScreenCycleSystem(material));
    final seen = <String>[];
    // Just short of nine seconds, where it would start again.
    for (var i = 0; i < 9 * 60 - 1; i++) {
      world.update(1 / 60);
      if (seen.isEmpty || seen.last != material.material) {
        seen.add(material.material);
      }
    }
    expect(seen, [
      'assets/materials/pixelate.material2d.json',
      'assets/materials/crt.material2d.json',
      'assets/materials/grade.material2d.json',
    ]);
  });
}
