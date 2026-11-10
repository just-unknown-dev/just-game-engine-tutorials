import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// The game as one screen of a larger app: the screen's State owns the engine.
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );

  @override
  void initState() {
    super.initState();
    engine.initialize().then((_) => engine.start());
  }

  @override
  void dispose() {
    unawaited(engine.dispose()); // final: this engine cannot start again
    super.dispose();
  }

  // GameWidget may be built before initialize() finishes: it starts
  // drawing and ticking the engine as soon as it is ready.
  @override
  Widget build(BuildContext context) => GameWidget(engine: engine);
}
