# 14 Virtual cameras

After this episode, you can frame a player with a shot that follows it, keep the view inside the level, switch shots with a trigger and blend between them, shake the view, show letterbox bars, and keep several players in one view.

Docs: https://engine.justunknown.com/docs/cameras

## cameras_basics/

A Flutter app with the engine: three programs, each as on screen, and their tests.

| Program | What it shows | Run it |
|---|---|---|
| `lib/main.dart` | A virtual camera that follows the player, framed and kept inside the level. | `flutter run` |
| `lib/shots.dart` | Two shots, a trigger that switches between them, blends, a shake and letterbox bars. | `flutter run -t lib/shots.dart` |
| `lib/group.dart` | One shot that keeps two players in view, zooming out as they spread. | `flutter run -t lib/group.dart` |

```text
cd cameras_basics
flutter run
flutter test
```
