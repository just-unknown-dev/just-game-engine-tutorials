// The two programs the episode shows do what it says: the sun and the box are drawn and the box drifts
// down at 40 units a second; the ball falls onto the floor and settles there.
import 'package:first_game/ball.dart' as ball;
import 'package:first_game/main.dart' as first;
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';

Future<Engine> run(WidgetTester tester, Future<void> Function() main) async {
  await tester.runAsync(main);
  await tester.pump();
  return tester.widget<GameWidget>(find.byType(GameWidget)).engine;
}

Future<void> seconds(WidgetTester tester, double s) async {
  for (var i = 0; i < (s * 60).round(); i++) {
    await tester.pump(const Duration(microseconds: 1000000 ~/ 60));
  }
}

void main() {
  testWidgets('the first game: a sun, and a box drifting down', (tester) async {
    final engine = await run(tester, first.main);
    final sun = engine.world.findEntityByName('Sun')!;
    final box = engine.world.findEntityByName('Box')!;
    expect(sun.getComponent<TransformComponent>()!.position.x, -150);
    expect(box.getComponent<RenderableComponent>(), isNotNull, reason: 'shapes are stored as a RenderableComponent');

    final y0 = box.getComponent<TransformComponent>()!.position.y;
    await seconds(tester, 1);
    final y1 = box.getComponent<TransformComponent>()!.position.y;
    expect(y1 - y0, closeTo(40, 2), reason: '40 units a second, down the screen (+Y)');
    await tester.runAsync(engine.dispose);
  });

  testWidgets('the floor and the ball: it falls and settles on the floor', (tester) async {
    final engine = await run(tester, ball.main);
    final b = engine.world.findEntityByName('Ball')!;
    final y0 = b.getComponent<TransformComponent>()!.position.y;
    expect(y0, -150);
    await seconds(tester, 4);
    final y = b.getComponent<TransformComponent>()!.position.y;
    // The floor's top is 200 - 12; the ball's centre rests a radius (24) above it.
    expect(y, closeTo(200 - 12 - 24, 2));
    await tester.runAsync(engine.dispose);
  });
}
