// The game's rules: the player runs, the enemies patrol, and the goal ends
// the level.
import 'dart:math';

import 'package:just_game_engine/just_game_engine.dart';

/// Where an enemy patrols around.
class PatrolComponent extends Component {
  PatrolComponent({required this.originX});

  final double originX;
}

/// Fired when the player reaches the goal.
class GoalReached extends GameEvent {}

/// Runs the player to the right.
class RunSystem extends System {
  @override
  int get priority => SystemPriorities.playerControl;

  @override
  List<Type> get requiredComponents => [VelocityComponent, TagComponent];

  @override
  void update(double deltaTime) {
    final player = world.findTagged('player');
    player?.getComponent<VelocityComponent>()!.velocity.x = 320;
  }
}

/// Swings every enemy back and forth around where it was spawned.
class PatrolSystem extends System {
  double _time = 0;

  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TransformComponent, TagComponent];

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    for (final enemy in world.allTagged('enemy')) {
      final patrol = enemy.getComponent<PatrolComponent>()!;
      enemy.getComponent<TransformComponent>()!.position.x =
          patrol.originX + sin(_time * 2) * 90;
    }
  }
}

/// Fires [GoalReached] when the player gets to the goal, and removes the
/// goal so it fires once.
class GoalSystem extends System {
  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TransformComponent, TagComponent];

  @override
  void update(double deltaTime) {
    final player = world.findTagged('player');
    final goal = world.findTagged('goal');
    if (player == null || goal == null) return;
    final px = player.getComponent<TransformComponent>()!.position.x;
    if (px >= goal.getComponent<TransformComponent>()!.position.x) {
      world.events.fire(GoalReached());
      world.commands.destroy(goal);
    }
  }
}
