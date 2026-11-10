# 08 Build a level with the Level Designer

After this episode, you can block out a level with tiles that collide, place prefabs, and play it.

Docs: https://engine.justunknown.com/docs/level-maps

## my_game/

Episode 07's project with `level_02` built in the Level Designer and saved, and one change in code: the player spawner gives the player a body and a collider (`lib/game/game_boot.dart`).

```text
cd my_game
just game run --editor     # the game with the editor (desktop)
just game run              # the game
flutter test
```

The `just` tool installs with `dart pub global activate just_core_cli` (episode 02).
