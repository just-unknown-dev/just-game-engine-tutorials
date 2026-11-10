// The episode's programs do what it says they do.
import 'package:effects_basics/effects.dart' as effects;
import 'package:effects_basics/main.dart' as particles;
import 'package:effects_basics/torch.dart' as torch;
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';

Future<Engine> run(WidgetTester tester, Future<void> Function() main) async {
  await tester.runAsync(main);
  await tester.pump();
  return tester.widget<GameWidget>(find.byType(GameWidget)).engine;
}

/// Frames at 60 a second, with real time between them for the atlases to load.
Future<void> seconds(WidgetTester tester, double s) async {
  for (var i = 0; i < (s * 60).round(); i++) {
    await tester.pump(const Duration(microseconds: 1000000 ~/ 60));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1)),
    );
  }
}

ParticleEmitter emitterOf(Entity e) =>
    e.getComponent<ParticleEmitterComponent>()!.emitter;

void main() {
  testWidgets('particles: six presets emitting, explosions that clean up', (
    tester,
  ) async {
    final engine = await run(tester, particles.main);
    final world = engine.world;
    await seconds(tester, 1);
    for (final name in [
      'Fire',
      'Smoke',
      'Sparkle',
      'Magic',
      'Portal',
      'Sparks',
    ]) {
      expect(
        emitterOf(world.findEntityByName(name)!).particleCount,
        greaterThan(0),
        reason: name,
      );
    }
    int explosions() =>
        world.entities.where((e) => e.name == 'Explosion').length;
    expect(explosions(), 0);
    await seconds(tester, 1.2); // one at 2 s
    expect(explosions(), 1);
    await seconds(tester, 5); // each goes when its last particle does
    expect(explosions(), lessThanOrEqualTo(2));
    await tester.runAsync(engine.dispose);
  });

  testWidgets('torch: three flames, each 40 above its torch', (tester) async {
    final engine = await run(tester, torch.main);
    final world = engine.world;
    final flames = world.entities.where((e) => e.name == 'Flame').toList();
    expect(flames, hasLength(3));
    await seconds(tester, 1);
    for (final flame in flames) {
      final parent = flame.getComponent<ParentComponent>()!;
      final at = flame.getComponent<TransformComponent>()!.position;
      final torchAt = world
          .getEntity(parent.parentId!)!
          .getComponent<TransformComponent>()!
          .position;
      expect(at.y, closeTo(torchAt.y - 40, 0.01));
      expect(emitterOf(flame).particleCount, greaterThan(10));
    }
    await tester.runAsync(engine.dispose);
  });

  testWidgets('effects: the same ticks give the same frames', (tester) async {
    Future<List<double>> sample() async {
      final engine = await run(tester, effects.main);
      final world = engine.world;
      await seconds(tester, 1.5);
      final out = [
        for (final e in world.entities.where(
          (e) => e.name == 'Coin' || e.name == 'Spirit',
        )) ...[
          e.getComponent<TransformComponent>()!.position.x,
          e.getComponent<TransformComponent>()!.position.y,
        ],
      ];
      await tester.runAsync(engine.dispose);
      return out;
    }

    final a = await sample();
    final b = await sample();
    expect(a, isNotEmpty);
    expect(a, b, reason: 'deterministic');
  });
}
