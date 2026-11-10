import 'package:just_game_engine/just_game_engine.dart';

import 'spinner.dart';

/// Registers the game's components on the engine it is given, and again,
/// as the code now makes them, after a hot reload.
class MyGameExtension implements RefreshableExtension {
  const MyGameExtension();

  @override
  String get id => 'my_game';

  @override
  void install(EngineContext context) =>
      context.definitions.register(spinnerDefinition);

  @override
  void refresh(EngineContext context) =>
      context.definitions.refresh([spinnerDefinition]);
}
