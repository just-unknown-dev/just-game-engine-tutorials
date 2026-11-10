# 15 Timelines

After this episode, you can key component fields over time in a timeline file, play it from code or a trigger, build one in code, run a cut-scene of block tracks, start timelines with signals, and open one in the editor's Timeline dock.

Docs: https://engine.justunknown.com/docs/timelines

## timelines_basics/

A Flutter app with the engine: three programs, each as on screen, and their tests.

| Program | What it shows | Run it |
|---|---|---|
| `lib/main.dart` | A door that a timeline opens: played by a trigger as the player comes, and played backwards as they go. | `flutter run` |
| `lib/coins.dart` | A timeline built in code: coins that bob, one asset for all of them. | `flutter run -t lib/coins.dart` |
| `lib/cutscene.dart` | A cut-scene on one clock: a camera shot, a sprite clip, a move, an entity switched on, and an event that is also a signal. | `flutter run -t lib/cutscene.dart` |

```text
cd timelines_basics
flutter run
flutter test
```

## my_game/

Made with `just create`, with the door in `level_01`.

```text
cd my_game
just game run --editor     # the game with the editor (desktop)
just game run              # the game
flutter test
```

The `just` tool installs with `dart pub global activate just_core_cli` (episode 02).
