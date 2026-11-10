// A cut-scene on one clock: a camera shot, a sprite clip, a move, an
// entity switched on, and an event that is also a signal. Run it with
//
//     flutter run -t lib/cutscene.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// The lanterns' flash: a quick pop, played when the "fight" signal comes.
final pop = TimelineAsset(
  name: 'lantern_pop',
  duration: 0.6,
  tracks: [
    for (final channel in ['x', 'y'])
      PropertyTrack(
        component: 'TransformComponent',
        field: 'scale',
        channel: channel,
        mode: PropertyTrackMode.relative,
        curve: KeyCurve(const [
          TimelineKey(
            time: 0,
            value: 0,
            interpolation: KeyInterpolation.linear,
          ),
          TimelineKey(time: 0.15, value: 0.5),
          TimelineKey(time: 0.6, value: 0),
        ]),
      ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.rendering.backgroundColor = const Color(0xFF1B1830);

  final world = engine.world;
  Entity sprite(String name, String image, double x, double y) =>
      world.createEntityWithComponents([
        TransformComponent(position: Vector3(x, y, 0)),
        SpriteComponent(
          spritePath: 'assets/sprites/$image.png',
          pixelArt: true,
        ),
        LayerComponent(layer: LevelLayers.background),
      ], name: name);

  // The shrine: the ground, a torii gate, and two lanterns that pop when
  // the "fight" signal comes.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(0, 70, 0)),
    Rectangle2DComponent(
      width: 1600,
      height: 60,
      fillStyle: const ShapePaintStyle(color: Color(0xFF2B2440)),
    ),
  ], name: 'Ground');
  sprite('Torii', 'forest_torii', 200, -44);
  for (final x in [60.0, 340.0]) {
    final lantern = sprite('Lantern', 'forest_lantern', x, 2);
    lantern.addComponent(
      TimelinePlayerComponent(inline: pop, listenSignal: 'fight'),
    );
  }

  // The oni stands still (speed 0) until its clip block plays.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(320, 23, 0)),
    SpriteAnimationComponent(
      atlasPath: 'assets/sprites/ninja_oni_forest.json',
      clip: 'walk',
      speed: 0,
    ),
    LayerComponent(zOrder: 10),
  ], name: 'Oni');

  // Switched on by the timeline's activation track.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(200, -96, 0)),
    Rectangle2DComponent(
      width: 120,
      height: 18,
      fillStyle: const ShapePaintStyle(color: Color(0xFFF5746F)),
    ),
  ], name: 'Banner').isActive = false;

  // Two shots: a wide one, and the gate up close that the cut-scene takes.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(200, -50, 0)),
    VirtualCameraComponent(zoom: 2.8),
  ], name: 'WideCam');
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(220, -20, 0)),
    VirtualCameraComponent(zoom: 4.5, priority: 0),
  ], name: 'GateCam');

  // The cut-scene itself.
  world.createEntityWithComponents([
    TransformComponent(),
    TimelinePlayerComponent(
      timelinePath: 'assets/timelines/gate_intro.timeline.json',
      playOnStart: true,
    ),
  ], name: 'Intro');

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
