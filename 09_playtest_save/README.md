# 09 Play-test, save and recover

After this episode, you can play a level in place, save it, get unsaved work back from a backup, step back through your edits, and clear what the Problems dock finds.

Docs: https://engine.justunknown.com/docs/editor

## my_game/

Episode 08's project as it is: the level to play-test, save and recover.

```text
cd my_game
just game run --editor     # the game with the editor (desktop)
just game run              # the game
flutter test
```

The `just` tool installs with `dart pub global activate just_core_cli` (episode 02).
