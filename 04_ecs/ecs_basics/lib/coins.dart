// Events and deferred changes. Run it with
//
//     flutter run -t lib/coins.dart
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Fired when the player picks up a coin.
class CoinCollected extends GameEvent {
  CoinCollected(this.value);

  final int value;
}

/// Collects every coin the player touches.
class CoinSystem extends System {
  @override
  int get priority => SystemPriorities.gameplay;

  @override
  List<Type> get requiredComponents => [TagComponent];

  @override
  void update(double deltaTime) {
    final player = world.findTagged('player');
    if (player == null) return;
    for (final coin in world.allTagged('coin')) {
      if (isTouching(coin, player)) {
        world.events.fire(CoinCollected(10));
        world.commands.destroy(coin); // applied after this system
      }
    }
  }

  bool isTouching(Entity a, Entity b) {
    final pa = a.getComponent<TransformComponent>()!.position;
    final pb = b.getComponent<TransformComponent>()!.position;
    return pa.distanceTo(pb) < 50;
  }
}

/// The score, kept by whoever listens for the event.
final score = ValueNotifier(0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();

  final world = engine.world;
  world.addSystem(CoinSystem());

  // The player drives right, through a row of coins.
  world.createEntityWithComponents([
    TransformComponent(position: Vector3(-800, 0, 0)),
    VelocityComponent(velocity: Vector3(240, 0, 0)),
    Rectangle2DComponent(
      width: 60,
      height: 60,
      cornerRadius: 8,
      fillStyle: const ShapePaintStyle(color: Colors.lightBlue),
    ),
    TagComponent('player'),
  ], name: 'Player');
  for (var i = 0; i < 8; i++) {
    world.createEntityWithComponents([
      TransformComponent(position: Vector3(-525 + i * 150.0, 0, 0)),
      Circle2DComponent(
        radius: 22,
        fillStyle: const ShapePaintStyle(color: Colors.amber),
      ),
      TagComponent('coin'),
    ], name: 'Coin');
  }

  // Listen for the event: ten points a coin.
  world.events.on<CoinCollected>((event) => score.value += event.value);

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          engine: engine,
          overlay: ValueListenableBuilder(
            valueListenable: score,
            builder: (context, value, _) => Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Text(
                  'Score $value',
                  style: const TextStyle(color: Colors.amber, fontSize: 44),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
