# 10 Your own components in the editor

After this episode, your component shows in the inspector and saves in scenes, your prefab is in the Level Designer, and a field you add appears after a hot reload.

Docs: https://engine.justunknown.com/docs/editor

## my_game/

Episode 08's project with a Spinner component: `lib/game/spinner.dart` (the component, its definition and its system), `lib/game/my_game_extension.dart` (a `RefreshableExtension`, in `GameBoot.extensions`) and `lib/editor/my_game_module.dart` (an `EditorModule` with a shared prefab, in `EditorWiring.modules()`).

```text
cd my_game
just game run --editor     # the game with the editor (desktop)
just game run              # the game
flutter test
```

The `just` tool installs with `dart pub global activate just_core_cli` (episode 02).
