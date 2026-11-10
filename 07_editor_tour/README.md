# 07 A tour of the editor

After this episode, you can open the editor, make a scene, and find every tool.

Docs: https://engine.justunknown.com/docs/editor

## my_game/

Made with `just create my_game --title "My Game"`, plus the level the episode makes: `assets/scenes/level_02.scene.json`.

```text
cd my_game
just game run --editor     # the game with the editor (desktop)
just game run              # the game
flutter test
```

The `just` tool installs with `dart pub global activate just_core_cli` (episode 02).
