// The episode's programs do what it says they do.
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:sprites_basics/animator.dart' as animator;
import 'package:sprites_basics/main.dart' as sprites;

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

void main() {
  testWidgets('sprites: images, a region, and every clip playing', (
    tester,
  ) async {
    final engine = await run(tester, sprites.main);
    final world = engine.world;
    await seconds(tester, 1);
    expect(
      world
          .findEntityByName('Smooth barrel')!
          .getComponent<SpriteComponent>()!
          .pixelArt,
      isFalse,
    );
    expect(
      world
          .findEntityByName('Crisp barrel')!
          .getComponent<SpriteComponent>()!
          .pixelArt,
      isTrue,
    );
    final statue = world
        .findEntityByName('Statue')!
        .getComponent<SpriteComponent>()!;
    expect(statue.region, 'player 0');
    expect(statue.flipX, isTrue);

    final atlas = (await tester.runAsync(
      () => SpriteAtlas.fromAsset(sprites.ninja, assets: engine.assets),
    ))!;
    expect(atlas.clipNames, containsAll(['idle', 'run', 'jump', 'fall']));
    for (final clip in ['idle', 'run', 'jump', 'fall']) {
      final sprite = world
          .findEntityByName('Ninja $clip')!
          .getComponent<SpriteAnimationComponent>()!;
      expect(sprite.playingClip, clip);
      expect(sprite.isPlaying, isTrue);
    }
    final coin = world
        .findEntityByName('Coin')!
        .getComponent<SpriteAnimationComponent>()!;
    final frames = <int>{};
    for (var i = 0; i < 40; i++) {
      await seconds(tester, 1 / 60);
      frames.add(coin.frameIndex);
    }
    expect(frames.length, greaterThan(2), reason: 'the coin spins');
    await tester.runAsync(engine.dispose);
  });

  testWidgets(
    'animator: the graph picks the clips, and faces the way it moves',
    (tester) async {
      final engine = await run(tester, animator.main);
      final world = engine.world;
      final ninja = world.findEntityByName('Ninja')!;
      final sprite = ninja.getComponent<SpriteAnimationComponent>()!;
      final seen = <String>[];
      world.getSystem<AnimatorSystem>()!.stateChanges.listen(
        (c) => seen.add(c.to),
      );

      await seconds(tester, 2.0); // sprinting right, then the jump at 1.6 s
      expect(seen, containsAllInOrder(['move', 'jump']));
      expect(sprite.playingFlipX, isFalse, reason: 'facing right');
      await seconds(tester, 1.2); // landed, then waiting
      expect(seen, containsAllInOrder(['move', 'jump', 'fall']));
      expect(animator.state.value, 'idle');
      await seconds(tester, 1.2); // jogging back
      expect(ninja.getComponent<AnimatorComponent>()!.currentState, 'move');
      expect(
        sprite.playingFlipX,
        isTrue,
        reason: 'faceVelocity turned it round',
      );
      expect(sprite.flipX, isFalse, reason: 'what was authored is left alone');
      await tester.runAsync(engine.dispose);
    },
  );
}
