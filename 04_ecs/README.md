# 04 Entities, components and systems

After this episode, you can write your own component and system, find entities with queries, send events, defer changes, make prefabs in code and build parents and children.

Docs: https://engine.justunknown.com/docs/ecs

## ecs_basics/

A Flutter app with the engine: five programs, each as on screen, and their tests.

| Program | What it shows | Run it |
|---|---|---|
| `lib/main.dart` | Your own component and system. | `flutter run` |
| `lib/swarm.dart` | One system, six hundred entities. | `flutter run -t lib/swarm.dart` |
| `lib/coins.dart` | Events and deferred changes. | `flutter run -t lib/coins.dart` |
| `lib/bullets.dart` | A prefab in code. | `flutter run -t lib/bullets.dart` |
| `lib/tank.dart` | Parents and children. | `flutter run -t lib/tank.dart` |

```text
cd ecs_basics
flutter run
flutter test
```
