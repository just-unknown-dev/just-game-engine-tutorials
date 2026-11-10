# 16 Particles, effects and post-processing

After this episode, you can add ready-made and your own particle emitters, with forces, run deterministic effects that play the same everywhere, and put a fragment shader over the whole frame.

Docs: https://engine.justunknown.com/docs/particles

## effects_basics/

A Flutter app with the engine: four programs, each as on screen, and their tests.

| Program | What it shows | Run it |
|---|---|---|
| `lib/main.dart` | Ready-made particle effects, and an explosion that cleans up after itself. | `flutter run` |
| `lib/torch.dart` | An emitter of your own: flames on wall torches, pushed by forces. | `flutter run -t lib/torch.dart` |
| `lib/effects.dart` | Deterministic effects: they count ticks, so they play the same on every machine. | `flutter run -t lib/effects.dart` |
| `lib/vignette.dart` | A fragment shader over the whole frame: a vignette over the torches. | `flutter run -t lib/vignette.dart` |

```text
cd effects_basics
flutter run
flutter test
```
