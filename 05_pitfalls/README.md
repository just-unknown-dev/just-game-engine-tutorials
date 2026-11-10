# 05 Five things that trip people up

After this episode, you avoid the five mistakes the docs call out.

Docs: https://engine.justunknown.com/docs/quick-start

## pitfalls/

A Flutter app with the engine: five programs, each as on screen, and their tests.

| Program | What it shows | Run it |
|---|---|---|
| `lib/steps.dart` | One: the world updates in fixed steps. | `flutter run -t lib/steps.dart` |
| `lib/axes.dart` | Two: +Y is down. | `flutter run -t lib/axes.dart` |
| `lib/turret.dart` | Three: TransformComponent is the world transform. | `flutter run -t lib/turret.dart` |
| `lib/priority.dart` | Four: systems run by priority, highest first. | `flutter run -t lib/priority.dart` |
| `lib/one_of_each.dart` | Five: one component of each type per entity. | `flutter run -t lib/one_of_each.dart` |
| `lib/main.dart` | Starts the first demo (`lib/steps.dart`). | `flutter run` |

```text
cd pitfalls
flutter run -t lib/steps.dart
flutter test
```
