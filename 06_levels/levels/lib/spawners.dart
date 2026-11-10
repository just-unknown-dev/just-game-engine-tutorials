import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

import 'game.dart';

/// What the levels' spawn points can create.
final spawners = [
  Spawner(
    id: 'player',
    label: 'Player',
    tags: const {'player'}, // the tags the spawned entity carries
    spawn: (world, point) => world.createEntityWithComponents([
      // The spawn point's position; TransformComponent copies it.
      TransformComponent(
        position: point.getComponent<TransformComponent>()?.position,
      ),
      VelocityComponent(),
      Rectangle2DComponent(
        width: 40,
        height: 56,
        cornerRadius: 8,
        fillStyle: const ShapePaintStyle(color: Colors.lightBlue),
      ),
      RigidBody2DComponent(friction: 0, lockRotation: true),
      Collider2DComponent(shape: Collider2DShape.matchShape),
      TagComponent('player'), // the scene's camera follows this tag
    ], name: 'Player'),
  ),
  Spawner(
    id: 'enemy',
    label: 'Enemy',
    tags: const {'enemy'},
    spawn: (world, point) {
      final at = point.getComponent<TransformComponent>()!.position;
      return world.createEntityWithComponents([
        TransformComponent(position: at),
        Rectangle2DComponent(
          width: 48,
          height: 48,
          cornerRadius: 6,
          fillStyle: const ShapePaintStyle(color: Color(0xFFF5746F)),
        ),
        PatrolComponent(originX: at.x),
        TagComponent('enemy'),
      ], name: 'Enemy');
    },
  ),
];
