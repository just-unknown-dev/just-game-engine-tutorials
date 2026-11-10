// A fragment shader over the whole frame: a vignette over the torches.
// Run it with
//
//     flutter run -t lib/vignette.dart
//
// Post-process passes need Impeller. On the web, and where Flutter draws
// with Skia, the engine skips them: the frame draws unshaded, and one line
// is logged.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'torch.dart' as torch;

Future<void> addVignette(Engine engine) async {
  final world = engine.world;
  if (!world.hasSystem<PostProcessSystem>()) {
    world.addSystem(
      PostProcessSystem(engine.rendering, getTime: () => engine.time.totalTime),
    );
  }
  final program = await ui.FragmentProgram.fromAsset('shaders/vignette.frag');
  world.createEntityWithComponents([
    ShaderComponent(
      program: program,
      isPostProcess: true,
      setUniforms: (shader, width, height, time) {
        shader
          ..setFloat(0, width) // uResolution.x
          ..setFloat(1, height) // uResolution.y
          ..setFloat(2, time); // uTime
      },
    ),
  ], name: 'Vignette');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = await torch.torchScene();
  await addVignette(engine);
  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
