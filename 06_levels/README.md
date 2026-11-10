# 06 Levels: scene files, spawn points and spawners

After this episode, you can write a level as a scene file, load it, fill its spawn points from your spawners, follow the player with the level's camera, change levels and handle a scene that won't load.

Docs: https://engine.justunknown.com/docs/scenes

## levels/

A Flutter app with the engine: two programs, each as on screen, and their tests.

| Program | What it shows | Run it |
|---|---|---|
| `lib/main.dart` | Levels from scene files. | `flutter run` |
| `lib/overview.dart` | The whole of level 1, standing still, with its spawn points marked. | `flutter run -t lib/overview.dart` |

```text
cd levels
flutter run
flutter test
```
