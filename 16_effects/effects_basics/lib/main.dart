// Ready-made particle effects, and an explosion that cleans up after
// itself. Run it with
//
//     flutter run
import 'package:flutter/material.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// A one-shot explosion; the entity goes when its last particle does.
void explode(World world, Vector3 at) => world.createEntityWithComponents([
  TransformComponent(position: at),
  ParticleEmitterComponent(
    emitter: ParticleEffects.explosion(position: at, color: Colors.amber),
    removeEntityWhenComplete: true,
  ),
], name: 'Explosion');

/// Sets one off every two seconds, in turn at three places.
class FireworksSystem extends System {
  double _time = 0;
  int _count = 0;

  @override
  List<Type> get requiredComponents => const [];

  @override
  void update(double deltaTime) {
    _time += deltaTime;
    if (_time < 2) return;
    _time -= 2;
    explode(world, Vector3(-500.0 + 500 * (_count++ % 3), -250, 0));
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = Engine(
    config: const EngineConfig(defaultSystems: DefaultSystems.all),
  );
  await engine.initialize();
  engine.rendering.backgroundColor = const Color(0xFF101426);

  final world = engine.world;
  // Not a default system: add it once.
  world.addSystem(ParticleSystem());
  world.addSystem(FireworksSystem());

  // Six of the ready-made emitters, in a row.
  final presets = <String, ParticleEmitter Function(Vector3)>{
    'Fire': (at) => ParticleEffects.fire(position: at),
    'Smoke': (at) => ParticleEffects.smoke(position: at),
    'Sparkle': (at) => ParticleEffects.sparkle(position: at, duration: null),
    'Magic': (at) => ParticleEffects.magic(position: at),
    'Portal': (at) => ParticleEffects.portal(position: at),
    'Sparks': (at) => ParticleEffects.electricSparks(position: at),
  };
  var x = -750.0;
  for (final MapEntry(key: name, value: make) in presets.entries) {
    final at = Vector3(x, 200, 0);
    world.createEntityWithComponents([
      TransformComponent(position: at),
      ParticleEmitterComponent(emitter: make(at)),
    ], name: name);
    x += 300;
  }

  engine.start();
  runApp(
    MaterialApp(
      home: Scaffold(body: GameWidget(engine: engine)),
    ),
  );
}
