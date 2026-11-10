# Just Game Engine tutorials: the code

The code from the Just Game Engine tutorial series, one folder per episode: each project as the episode
leaves it, with its tests.

Written for Just Game Engine 2.0.0, its editor 0.1.0 and Flutter 3.47.9.
Docs: https://engine.justunknown.com/docs

## Episodes

| # | Episode | Code |
|---|---|---|
| 01 | What is Just Game Engine? | An overview: no code. |
| 02 | [Install and create your first project](02_install/) | `my_game/`, made with `just create` |
| 03 | [Your first game in code](03_first_game/) | `first_game/`: 2 programs |
| 04 | [Entities, components and systems](04_ecs/) | `ecs_basics/`: 5 programs |
| 05 | [Five things that trip people up](05_pitfalls/) | `pitfalls/`: 5 programs |
| 06 | [Levels: scene files, spawn points and spawners](06_levels/) | `levels/`: 2 programs |
| 07 | [A tour of the editor](07_editor_tour/) | `my_game/`, made with `just create` |
| 08 | [Build a level with the Level Designer](08_level_designer/) | `my_game/`, made with `just create` |
| 09 | [Play-test, save and recover](09_playtest_save/) | `my_game/`, made with `just create` |
| 10 | [Your own components in the editor](10_own_components/) | `my_game/`, made with `just create` |
| 11 | The Asset Store: kits and plugins | The Asset Store, browsed in episode 07's project: no code of its own. |
| 12 | [Shapes, layers and draw order](12_rendering/) | `rendering_basics/`: 6 programs |
| 13 | [Sprites and animator graphs](13_sprites/) | `sprites_basics/`: 2 programs; `my_game/`, made with `just create` |
| 14 | [Virtual cameras](14_cameras/) | `cameras_basics/`: 3 programs |
| 15 | [Timelines](15_timelines/) | `timelines_basics/`: 3 programs; `my_game/`, made with `just create` |
| 16 | [Particles, effects and post-processing](16_effects/) | `effects_basics/`: 4 programs |
| 17 | [2D lighting, shadows and materials](17_lighting/) | `lighting_basics/`: 3 programs; `my_game/`, made with `just create` |

## Run the code

Each project stands on its own. The code episodes are Flutter apps whose programs in `lib/` each run on
their own:

```text
cd 04_ecs/ecs_basics
flutter run -t lib/swarm.dart
flutter test
```

The editor episodes' `my_game/` folders are games made with `just create`. Install the `just` tool once
(episode 02), then run a game with its editor from its folder:

```text
dart pub global activate just_core_cli
cd 09_playtest_save/my_game
just game run --editor
```

## Check every project

`dart tool/check_all.dart` runs `flutter pub get`, `flutter analyze` and `flutter test` in every project.
Name steps or episodes to run fewer: `dart tool/check_all.dart test 04 13`.
