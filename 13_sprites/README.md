# 13 Sprites and animator graphs

After this episode, you can show images and atlas frames, play clips from an atlas, and let an animator graph choose them from how an entity moves, with a blend tree, and watch it in the editor.

Docs: https://engine.justunknown.com/docs/sprites

## sprites_basics/

A Flutter app with the engine: two programs, each as on screen, and their tests.

| Program | What it shows | Run it |
|---|---|---|
| `lib/main.dart` | Images, atlas regions and clips. | `flutter run` |
| `lib/animator.dart` | An animator graph picks the ninja's clip. | `flutter run -t lib/animator.dart` |

```text
cd sprites_basics
flutter run
flutter test
```

## my_game/

Made with `just create`, its player spawner swapped for the ninja with the same animator graph (`lib/game/game_boot.dart`), and `level_01` given ground and the shrine.

```text
cd my_game
just game run --editor     # the game with the editor (desktop)
just game run              # the game
flutter test
```

The `just` tool installs with `dart pub global activate just_core_cli` (episode 02).
