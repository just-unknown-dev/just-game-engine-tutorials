// The editor's side of the game: only lib/main_editor.dart's imports reach
// this file, so none of it ships.
//
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:just_game_engine_editor/just_game_engine_editor.dart';

import '../game/spinner.dart';

class MyGameModule extends EditorModule {
  @override
  String get id => 'my_game';

  @override
  String get name => 'My Game';

  // In every Level Designer, beside the editor's own shapes.
  @override
  List<PrefabDefinition> get sharedPrefabs => [
    PrefabDefinition(
      id: 'my_game.spinner',
      name: 'Spinner',
      category: 'Hazards',
      icon: Icons.autorenew,
      color: const Color(0xFFF5746F),
      description: 'A square that turns.',
      placement: PrefabPlacement.point,
      defaultSize: const Size(64, 64),
      build: (position, size) => [
        TransformComponent(position: Vector3(position.dx, position.dy, 0)),
        Rectangle2DComponent(
          width: size.width,
          height: size.height,
          fillStyle: const ShapePaintStyle(color: Color(0xFFF5746F)),
        ),
        SpinnerComponent(),
      ],
    ),
  ];
}
