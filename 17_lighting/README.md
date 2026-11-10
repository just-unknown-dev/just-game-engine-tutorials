# 17 2D lighting, shadows and materials

After this episode, you can light a 2D scene with ambient, point and spot lights, give sprites depth with normal maps, cast shadows, draw sprites through 2D materials and change their values as the game runs, and draw the whole view through a screen material.

Docs: https://engine.justunknown.com/docs

## lighting_basics/

A Flutter app with the engine: three programs, each as on screen, and their tests.

| Program | What it shows | Run it |
|---|---|---|
| `lib/main.dart` | 2D lighting: ambient light, a point light and a spot light, normal-mapped rock, shadow casters and a glowing lantern. | `flutter run` |
| `lib/materials.dart` | 2D materials: each ninja drawn through a material file of its own. | `flutter run -t lib/materials.dart` |
| `lib/screen.dart` | Screen materials: the whole view drawn through a material, here over the lit cave. | `flutter run -t lib/screen.dart` |

```text
cd lighting_basics
flutter run
flutter test
```

## my_game/

Made with `just create`, its ninja given the outline material (`assets/materials/outline.material2d.json`) in `level_01`.

```text
cd my_game
just game run --editor     # the game with the editor (desktop)
just game run              # the game
flutter test
```

The `just` tool installs with `dart pub global activate just_core_cli` (episode 02).
