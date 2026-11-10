import 'dart:math' as math;

import 'package:flutter/material.dart' show Icons;
import 'package:just_game_engine/just_game_engine.dart';

/// Turns the entity it is on, [speed] degrees a second.
class SpinnerComponent extends Component {
  double speed = 90;
  bool clockwise = true;
}

// A getter, so a hot reload builds it again from the code.
ComponentDefinition<SpinnerComponent> get spinnerDefinition =>
    ComponentDefinition(
      type: 'SpinnerComponent',
      create: SpinnerComponent.new,
      fields: [
        FieldDefinition(
          name: 'speed',
          kind: FieldTypes.decimal,
          min: 0,
          max: 720,
          read: (c) => (c as SpinnerComponent).speed,
          write: (c, v) => (c as SpinnerComponent).speed = (v as num).toDouble(),
        ),
        FieldDefinition(
          name: 'clockwise',
          kind: FieldTypes.boolean,
          read: (c) => (c as SpinnerComponent).clockwise,
          write: (c, v) => (c as SpinnerComponent).clockwise = v as bool,
        ),
      ],
      // What the inspector shows. The game ignores it.
      hints: const ComponentHints(
        name: 'Spinner',
        group: 'Gameplay',
        icon: Icons.autorenew,
        description: 'Turns the entity it is on.',
        fields: {
          'speed': FieldHint(
            label: 'Speed',
            scrub: ScrubHint(step: 5, fractionDigits: 0, suffix: '°/s'),
          ),
          'clockwise': FieldHint(label: 'Clockwise'),
        },
      ),
    );

/// Turns every entity that has a transform and a spinner.
class SpinnerSystem extends System {
  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TransformComponent, SpinnerComponent];

  @override
  void update(double deltaTime) {
    forEach((entity) {
      final spinner = entity.getComponent<SpinnerComponent>()!;
      final turn = spinner.speed * math.pi / 180 * deltaTime;
      // Positive angles turn clockwise: +Y is down.
      entity.getComponent<TransformComponent>()!.angle +=
          spinner.clockwise ? turn : -turn;
    });
  }
}
