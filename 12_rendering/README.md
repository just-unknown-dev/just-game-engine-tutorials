# 12 Shapes, layers and draw order

After this episode, you can draw with the five built-in shapes, put things in front of and behind each other with layers and y-sorting, batch and cull many shapes, draw your own things, and put a parallax background behind the world.

Docs: https://engine.justunknown.com/docs/rendering

## rendering_basics/

A Flutter app with the engine: six programs, each as on screen, and their tests.

| Program | What it shows | Run it |
|---|---|---|
| `lib/main.dart` | The five shapes that draw themselves. | `flutter run` |
| `lib/layers.dart` | Draw order: layers, then zOrder. | `flutter run -t lib/layers.dart` |
| `lib/topdown.dart` | Top-down draw order: whatever stands lower on screen is in front. | `flutter run -t lib/topdown.dart` |
| `lib/batching.dart` | Batching and culling, with the render system's counts. | `flutter run -t lib/batching.dart` |
| `lib/custom.dart` | Drawing your own things: in the world, as a pass, and on the screen. | `flutter run -t lib/custom.dart` |
| `lib/parallax.dart` | A parallax background behind a scrolling world. | `flutter run -t lib/parallax.dart` |

```text
cd rendering_basics
flutter run
flutter test
```
