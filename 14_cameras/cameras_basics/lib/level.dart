// The level this episode's cameras look at, and a runner that plays a player.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

const noOutline = ShapePaintStyle(color: Colors.transparent);

/// Where a runner's middle is when it stands on the ground (whose top is at 720).
const groundY = 660.0;

/// A 4000 by 800 level, its middle at (2000, 400): a sky, towers, the
/// ground with a mark every 250 units, a gate at 3200 into the end room,
/// and the bounds a confiner keeps the view inside.
void buildLevel(World world) {
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(2000, 0, 0)),
    Rectangle2DComponent(
      width: 6400,
      height: 2400,
      fillStyle: const ShapePaintStyle(
        gradient: ShapeGradient.linear(
          // Pink at the horizon, where the ground's top is (720).
          colors: [Color(0xFF0B1028), Color(0xFF3A2B5C), Color(0xFFB8546A)],
          stops: [0.3, 0.62, 0.8],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      strokeStyle: noOutline,
    ),
    LayerComponent(layer: LevelLayers.background),
  ], name: 'Sky');

  final random = Random(14);
  for (var x = -400.0; x < 4400; x += 150) {
    final height = 160 + random.nextDouble() * 300;
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 720 - height / 2, 0)),
      Rectangle2DComponent(
        width: 110,
        height: height,
        fillStyle: const ShapePaintStyle(color: Color(0xFF2A2148)),
        strokeStyle: noOutline,
      ),
      LayerComponent(layer: LevelLayers.backgroundNear),
    ], name: 'Tower');
  }

  world.createEntityWithComponents([
    TransformComponent(position: Vector3(2000, 1320, 0)),
    Rectangle2DComponent(
      width: 6400,
      height: 1200,
      fillStyle: const ShapePaintStyle(color: Color(0xFF15112A)),
      strokeStyle: noOutline,
    ),
  ], name: 'Ground');

  for (var x = 0.0; x <= 4000; x += 250) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 734, 0)),
      Rectangle2DComponent(
        width: 8,
        height: 28,
        fillStyle: ShapePaintStyle(
          color: x % 1000 == 0 ? const Color(0xFFF5746F) : Colors.white38,
        ),
        strokeStyle: noOutline,
      ),
    ], name: 'Mark');
  }

  // The gate into the end room.
  for (final x in [3160.0, 3240.0]) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, 540, 0)),
      Rectangle2DComponent(
        width: 36,
        height: 360,
        fillStyle: const ShapePaintStyle(color: Color(0xFFD9606C)),
        strokeStyle: noOutline,
      ),
    ], name: 'Gate');
  }

  world.createEntityWithComponents([
    TransformComponent(position: Vector3(2000, 400, 0)),
    CameraBoundsComponent(width: 4000, height: 800),
  ], name: 'LevelBounds');
}

/// One leg of a run: how long, how fast, and whether it starts with a hop.
typedef Leg = ({double seconds, double speed, bool hop});

/// Runs its entity through [legs] on a loop, as a player pressing keys would.
class RunnerComponent extends Component {
  RunnerComponent(this.legs, {this.onLand});

  final List<Leg> legs;

  /// Called when the runner comes down from a hop.
  final void Function(Entity runner)? onLand;

  double time = 0;
}

/// Moves every runner: its leg's speed, a hop, gravity and the ground.
class RunnerSystem extends System {
  @override
  List<Type> get requiredComponents => [
    TransformComponent,
    VelocityComponent,
    RunnerComponent,
  ];

  @override
  void update(double deltaTime) {
    forEach((entity) {
      final runner = entity.getComponent<RunnerComponent>()!;
      final velocity = entity.getComponent<VelocityComponent>()!.velocity;
      final position = entity.getComponent<TransformComponent>()!.position;
      final total = runner.legs.fold(0.0, (n, leg) => n + leg.seconds);
      final before = runner.time;
      runner.time = (runner.time + deltaTime) % total;

      var start = 0.0;
      for (final leg in runner.legs) {
        if (runner.time < start + leg.seconds) {
          velocity.x = leg.speed;
          final began = before < start || before > runner.time;
          if (leg.hop && began && position.y >= groundY) velocity.y = -760;
          break;
        }
        start += leg.seconds;
      }

      // Gravity, and the ground.
      final airborne = position.y < groundY || velocity.y < 0;
      if (airborne) velocity.y += 2000 * deltaTime;
      if (position.y > groundY) {
        position.y = groundY;
        if (velocity.y > 0) {
          velocity.y = 0;
          runner.onLand?.call(entity);
        }
      }
    });
  }
}

/// A runner: a capsule tagged `player`, so the cameras can follow it.
Entity addRunner(
  World world,
  double x,
  List<Leg> legs, {
  Color color = const Color(0xFFF5746F),
  void Function(Entity runner)? onLand,
  String name = 'Player',
}) => world.createEntityWithComponents([
  TransformComponent(position: Vector3(x, groundY, 0)),
  VelocityComponent(),
  Capsule2DComponent(
    width: 56,
    height: 120,
    fillStyle: ShapePaintStyle(color: color),
  ),
  LayerComponent(zOrder: 10),
  TagComponent('player'),
  RunnerComponent(legs, onLand: onLand),
], name: name);
