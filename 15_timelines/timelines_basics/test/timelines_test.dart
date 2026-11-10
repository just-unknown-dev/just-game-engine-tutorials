// The episode's three programs do what it says they do.
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';
import 'package:timelines_basics/coins.dart' as coins;
import 'package:timelines_basics/cutscene.dart' as cutscene;
import 'package:timelines_basics/main.dart' as door;

Future<Engine> run(WidgetTester tester, Future<void> Function() main) async {
  await tester.runAsync(main);
  await tester.pump();
  return tester.widget<GameWidget>(find.byType(GameWidget)).engine;
}

/// Frames at 60 a second, with real time between them for the assets to load.
Future<void> seconds(WidgetTester tester, double s) async {
  for (var i = 0; i < (s * 60).round(); i++) {
    await tester.pump(const Duration(microseconds: 1000000 ~/ 60));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1)),
    );
  }
}

double y(Entity e) => e.getComponent<TransformComponent>()!.position.y;

void main() {
  testWidgets('door: opens as the walker comes, fires opened, and closes', (
    tester,
  ) async {
    final engine = await run(tester, door.main);
    final world = engine.world;
    final door_ = world.findEntityByName('Door')!;
    final events = <String>[];
    world.getSystem<TimelineSystem>()!.events.listen((e) => events.add(e.name));
    expect(y(door_), 220);
    await seconds(tester, 3.4); // the walker is under the doorway
    expect(y(door_), closeTo(220 - 240, 0.5), reason: 'open: 240 up');
    expect(events, contains('opened'));
    expect(door.lastEvent.value, 'Door: opened');
    await seconds(tester, 3.0); // gone through, and out of the doorway
    expect(y(door_), closeTo(220, 0.5), reason: 'played backwards: shut');
    await tester.runAsync(engine.dispose);
  });

  testWidgets('coins: one inline asset, relative, each at its own speed', (
    tester,
  ) async {
    final engine = await run(tester, coins.main);
    final all = engine.world.entities.where((e) => e.name == 'Coin').toList();
    expect(all, hasLength(7));
    await seconds(tester, 0.5);
    for (final coin in all) {
      expect(
        y(coin),
        inInclusiveRange(-12.01, 0.01),
        reason: 'within 12 of where it started',
      );
    }
    expect(
      {for (final c in all) y(c).toStringAsFixed(2)}.length,
      greaterThan(3),
      reason: 'out of step',
    );
    await tester.runAsync(engine.dispose);
  });

  testWidgets('cutscene: the shot, the walk, the banner and the signal', (
    tester,
  ) async {
    final engine = await run(tester, cutscene.main);
    final world = engine.world;
    final brain = engine.camera.brain;
    final oni = world.findEntityByName('Oni')!;
    final banner = world.findEntityByName('Banner')!;
    final lantern = world.entities.firstWhere((e) => e.name == 'Lantern');
    final x0 = oni.getComponent<TransformComponent>()!.position.x;
    await seconds(tester, 0.5);
    expect(brain.liveCamera?.name, 'WideCam');
    await seconds(tester, 1.5); // 2.0 s
    expect(brain.liveCamera?.name, 'GateCam');
    await seconds(tester, 2.2); // 4.2 s
    expect(
      oni.getComponent<TransformComponent>()!.position.x,
      closeTo(x0 - 120, 0.5),
    );
    expect(banner.isActive, isTrue);
    await seconds(tester, 0.9); // 5.1 s: the fight signal
    expect(
      lantern.getComponent<TransformComponent>()!.scale.x,
      greaterThan(1.1),
    );
    await seconds(tester, 0.6); // 5.7 s
    expect(brain.liveCamera?.name, 'WideCam');
    await tester.runAsync(engine.dispose);
  });
}
