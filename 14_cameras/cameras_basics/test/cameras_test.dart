// The episode's three programs do what it says they do.
import 'package:cameras_basics/group.dart' as group;
import 'package:cameras_basics/main.dart' as follow;
import 'package:cameras_basics/shots.dart' as shots;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine/just_game_engine.dart';

/// Runs [main] in a 1920 x 1080 view, the size the episode films at.
Future<Engine> run(WidgetTester tester, Future<void> Function() main) async {
  tester.view
    ..physicalSize = const Size(1920, 1080)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.runAsync(main);
  await tester.pump();
  return tester.widget<GameWidget>(find.byType(GameWidget)).engine;
}

Future<void> seconds(WidgetTester tester, double s) async {
  for (var i = 0; i < (s * 60).round(); i++) {
    await tester.pump(const Duration(microseconds: 1000000 ~/ 60));
  }
}

double x(Entity e) => e.getComponent<TransformComponent>()!.position.x;

void main() {
  testWidgets('follow: framed on the player, never outside the level', (
    tester,
  ) async {
    final engine = await run(tester, follow.main);
    final camera = engine.camera.mainCamera;
    final player = engine.world.findTagged('player')!;
    final framing = engine.world
        .findEntityByName('FollowCam')!
        .getComponent<CameraFramingComponent>()!;
    for (var t = 0; t < 16; t++) {
      await seconds(tester, 1);
      final view = camera.visibleBounds;
      expect(
        view.left,
        greaterThanOrEqualTo(-1),
        reason: 'confined at ${t + 1} s',
      );
      expect(
        view.right,
        lessThanOrEqualTo(4001),
        reason: 'confined at ${t + 1} s',
      );
      expect(view.top, greaterThanOrEqualTo(-1));
      expect(view.bottom, lessThanOrEqualTo(801));
      // Away from the level's ends, the player stays inside the soft zone.
      if (x(player) > 1400 && x(player) < 2600) {
        final soft = view.width * framing.softZoneWidth / 2;
        expect((x(player) - view.center.dx).abs(), lessThan(soft));
      }
    }
    expect(camera.zoom, closeTo(1.4, 1e-6));
    await tester.runAsync(engine.dispose);
  });

  testWidgets('shots: the room shot takes over inside, and lets go outside', (
    tester,
  ) async {
    final engine = await run(tester, shots.main);
    final brain = engine.camera.brain;
    await seconds(tester, 2);
    expect(brain.liveCamera?.name, 'FollowCam');
    await seconds(tester, 2.5); // through the gate at 3200
    expect(brain.liveCamera?.name, 'RoomCam');
    await seconds(tester, 4); // back out
    expect(brain.liveCamera?.name, 'FollowCam');
    await tester.runAsync(engine.dispose);
  });

  testWidgets(
    'group: zooms out as the players spread, and keeps them in view',
    (tester) async {
      final engine = await run(tester, group.main);
      final camera = engine.camera.mainCamera;
      final players = engine.world.allTagged('player').toList();
      expect(players, hasLength(2));
      await seconds(tester, 0.9);
      final together = camera.zoom;
      await seconds(tester, 3.5);
      final apart = camera.zoom;
      expect(apart, lessThan(together * 0.8));
      final view = camera.visibleBounds;
      for (final p in players) {
        expect(
          view.contains(Offset(x(p), 660)),
          isTrue,
          reason: '${p.name} in view',
        );
      }
      await tester.runAsync(engine.dispose);
    },
  );
}
