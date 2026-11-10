// An animator graph picks the ninja's clip. Run it with
//
//     flutter run -t lib/animator.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// The state the graph is in, for the label.
final state = ValueNotifier('idle');

/// Plays the part of a player, on an eight-second loop: wait, sprint right
/// and jump, wait, jog back and jump. It only sets the velocity: the graph
/// chooses the clips.
class CoachSystem extends System {
  double _time = 0;

  @override
  List<Type> get requiredComponents => [VelocityComponent, RigidBody2DComponent];

  @override
  void update(double deltaTime) {
    final before = _time;
    _time = (_time + deltaTime) % 8;
    bool reached(double t) => before < t && _time >= t;

    forEach((entity) {
      final velocity = entity.getComponent<VelocityComponent>()!.velocity;
      velocity.x = switch (_time) {
        < 1 => 0, // wait
        < 2.5 => 240, // sprint right
        < 3.5 => 0, // wait
        < 7.1 => -100, // jog back
        _ => 0,
      };
      final body = entity.getComponent<RigidBody2DComponent>()!;
      if ((reached(1.6) || reached(5.2)) && body.isGrounded) {
        velocity.y = -420; // up is negative: jump
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
  engine.camera.mainCamera
    ..lookAt(const Offset(0, -40))
    ..zoom = 4;

  // `grounded` is not a built-in binding, so teach it to this engine.
  engine.context.animatorBindings.register(
    'grounded',
    (entity) => entity.getComponent<RigidBody2DComponent>()?.isGrounded,
  );

  final world = engine.world;
  world.addSystem(CoachSystem());

  // Scenery: a torii gate and two lanterns, behind the ninja.
  for (final (x, y, image) in [
    (0.0, -44.0, 'forest_torii'),
    (-150.0, 2.0, 'forest_lantern'),
    (150.0, 2.0, 'forest_lantern'),
  ]) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(x, y, 0)),
      SpriteComponent(spritePath: 'assets/sprites/$image.png', pixelArt: true),
      LayerComponent(layer: LevelLayers.background),
    ], name: image);
  }

  // The ground: a collider alone is a static body.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 70, 0)),
    Rectangle2DComponent(
      width: 800,
      height: 60,
      fillStyle: const ShapePaintStyle(color: Color(0xFF2B2440)),
      strokeStyle: const ShapePaintStyle(color: Colors.transparent),
    ),
    Collider2DComponent(shape: Collider2DShape.matchShape),
  ], name: 'Ground');

  // The ninja: its graph picks the clip, and faceVelocity turns it round.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-170, 16, 0)),
    VelocityComponent(),
    SpriteAnimationComponent(atlasPath: 'assets/sprites/player.json'),
    AnimatorComponent(
      graphPath: 'assets/sprites/ninja.animator.json',
      faceVelocity: true,
    ),
    RigidBody2DComponent(friction: 0, lockRotation: true),
    Collider2DComponent(size: Vector2(20, 48)),
    LayerComponent(zOrder: 10),
  ], name: 'Ninja');

  // Every change of state, as it happens.
  world.getSystem<AnimatorSystem>()!.stateChanges.listen(
    (change) => state.value = change.to,
  );

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          engine: engine,
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: ValueListenableBuilder(
                valueListenable: state,
                builder: (context, name, _) => Text(
                  'state: $name',
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
