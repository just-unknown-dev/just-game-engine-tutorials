// A door that a timeline opens: played by a trigger as the player comes,
// and played backwards as they go. Run it with
//
//     flutter run
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// The last event a timeline fired, for the label.
final lastEvent = ValueNotifier('none yet');

/// Walks the walker from one side to the other and back.
class WalkSystem extends System {
  @override
  List<Type> get requiredComponents => [TransformComponent, VelocityComponent];

  @override
  void update(double deltaTime) {
    forEach((entity) {
      final x = entity.getComponent<TransformComponent>()!.position.x;
      final velocity = entity.getComponent<VelocityComponent>()!.velocity;
      if ((x > 760 && velocity.x > 0) || (x < -760 && velocity.x < 0)) {
        velocity.x = -velocity.x;
      }
    });
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.rendering.backgroundColor = const Color(0xFF1B1830);

  final world = engine.world;
  world.addSystem(WalkSystem());

  // The floor, and the wall above the doorway that the open door hides in.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 440, 0)),
    Rectangle2DComponent(
      width: 1920,
      height: 200,
      fillStyle: const ShapePaintStyle(color: Color(0xFF2B2440)),
    ),
  ], name: 'Floor');
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, -240, 0)),
    Rectangle2DComponent(
      width: 220,
      height: 680,
      fillStyle: const ShapePaintStyle(color: Color(0xFF3A2F5C)),
    ),
    LayerComponent(layer: LevelLayers.foreground),
  ], name: 'Wall');

  // The door: its player holds door_open.timeline.json.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 220, 0)),
    Rectangle2DComponent(
      width: 140,
      height: 240,
      cornerRadius: 6,
      fillStyle: const ShapePaintStyle(color: Color(0xFFD9606C)),
    ),
    TimelinePlayerComponent(
      timelinePath: 'assets/timelines/door_open.timeline.json',
    ),
  ], name: 'Door');

  // A 500 x 400 area round the doorway that plays the door's timeline when
  // a player walks in, and plays it backwards when they leave. It is an
  // entity of its own, so it stays put while the door moves.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 220, 0)),
    TimelineTriggerComponent(
      width: 500,
      height: 400,
      playerName: 'Door',
      enterAction: TimelineTriggerAction.play,
      exitAction: TimelineTriggerAction.reverse,
    ),
  ], name: 'Doorway');

  // The walker: tagged "player", so the trigger sees it.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-700, 280, 0)),
    VelocityComponent(velocity: Vector3(240, 0, 0)),
    Capsule2DComponent(
      width: 56,
      height: 120,
      fillStyle: const ShapePaintStyle(color: Color(0xFF54C5F8)),
    ),
    TagComponent('player'),
  ], name: 'Walker');

  // Events from every timeline in the world.
  world.getSystem<TimelineSystem>()!.events.listen(
    (event) => lastEvent.value = '${event.owner.name}: ${event.name}',
  );

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          engine: engine,
          overlay: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: ValueListenableBuilder(
                valueListenable: lastEvent,
                builder: (context, text, _) => Text(
                  'last event: $text',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
