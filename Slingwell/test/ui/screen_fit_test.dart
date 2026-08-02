import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slingwell/best_run.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/app.dart';
import 'package:slingwell/ui/camera.dart';
import 'package:slingwell/ui/game_loop.dart';
import 'package:slingwell/ui/game_screen.dart';
import 'package:slingwell/ui/game_view.dart';

/// The screens the game has to fit, in logical pixels: the smallest phone
/// either platform still runs on, the shapes in between, and a tablet, because
/// nothing stops one installing a phone game.
///
/// Written as physical pixels at three times the logical size, which is what
/// the view is handed.
const _screens = <String, Size>{
  'iPhone SE, 320 by 568': Size(960, 1704),
  'a small Android, 360 by 640': Size(1080, 1920),
  'iPhone 8, 375 by 667': Size(1125, 2001),
  'iPhone 14, 390 by 844': Size(1170, 2532),
  'Pixel 7, 412 by 915': Size(1236, 2745),
  'an iPad, 768 by 1024': Size(2304, 3072),
};

/// One ordinary setting, one large, and the largest a phone offers.
const _textScales = [1.0, 1.6, 2.0];

/// A best worth showing, so both cards are carrying their longest line rather
/// than the short one a fresh install gets.
const _record = <String, Object>{'best.score': 31, 'best.seed': 48213};

Future<void> _open(
  WidgetTester tester, {
  required Size screen,
  required double textScale,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(_record));
  final best = BestRun(await SharedPreferences.getInstance());
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(
        theme: SlingwellApp.theme,
        home: GameScreen(best: best, seeds: () => 3),
      ),
    ),
  );
  await tester.pump();
}

/// The middle of whatever glass this screen has, which is a thumb during a run
/// and nothing in particular on a card.
Offset _thumb(WidgetTester tester) => tester.getCenter(find.byType(GameView));

/// Plays the way a beginner does, letting go the moment anything catches,
/// which ends a run in a couple of seconds.
Future<void> _mashUntilOver(WidgetTester tester, String where) async {
  for (var frame = 0; frame < 900; frame++) {
    if (tester.any(find.text('Go again'))) return;
    await tester.tapAt(_thumb(tester));
    await tester.pump(const Duration(milliseconds: 16));
  }
  fail('the run never ended on $where');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('fits every screen at every text size, from title to card', (
    tester,
  ) async {
    addTearDown(tester.view.reset);

    for (final textScale in _textScales) {
      for (final screen in _screens.entries) {
        final where = '${screen.key} at text scale $textScale';
        await _open(tester, screen: screen.value, textScale: textScale);

        expect(find.text('Slingwell'), findsOneWidget, reason: where);
        expect(find.text('Tap to fly'), findsOneWidget, reason: where);
        expect(
          tester.takeException(),
          isNull,
          reason: 'the title overflowed on $where',
        );

        await tester.tapAt(_thumb(tester));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('wells'), findsOneWidget, reason: where);
        expect(
          tester.takeException(),
          isNull,
          reason: 'the score overflowed on $where',
        );

        await _mashUntilOver(tester, where);
        await tester.pump(const Duration(milliseconds: 500));
        expect(
          tester.takeException(),
          isNull,
          reason: 'the card at the end overflowed on $where',
        );

        // The way back in has to be reachable, which on a short screen at the
        // largest text means scrolling the card to it.
        await tester.ensureVisible(find.text('Go again'));
        await tester.pump();
        await tester.tap(find.text('Go again'));
        await tester.pump();
        expect(find.text('Go again'), findsNothing, reason: where);

        // A tree of its own for each shape, or the next one inherits this
        // one's state.
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  test('keeps the craft on the glass on every screen it runs on', () {
    // The craft is the one thing a player is watching, so it may not go off
    // the picture while a run is still going: not sideways as it drifts
    // towards a wall, and not off the bottom as it falls behind the climb.
    // Played two ways, because a beginner throwing a run away and a player
    // who has learnt it put the craft in different corners.
    for (final screen in _screens.values) {
      final size = screen / 3;
      for (var seed = 1; seed <= 40; seed++) {
        for (final beginner in const [true, false]) {
          final loop = GameLoop(seed: seed);
          for (var frame = 0; frame < 3000 && !loop.world.isOver; frame++) {
            if (beginner ? loop.world.isHeld : _aimed(loop.world)) loop.tap();
            loop.advance(const Duration(milliseconds: 16));

            final camera = Camera.forSize(size, loop.focusY);
            final where = 'seed $seed on ${size.width}x${size.height}';
            for (final corner in _hull(loop.world)) {
              final at = camera.toScreen(corner);
              expect(at.dx, inInclusiveRange(0, size.width), reason: where);
              expect(at.dy, inInclusiveRange(0, size.height), reason: where);
            }
          }
        }
      }
    }
  });
}

/// The corners of the craft as the painter draws it, in metres.
List<Vec> _hull(World world) {
  final way = world.velocity.length == 0
      ? const Vec(1, 0)
      : world.velocity.normalised;
  final side = way.perpendicular;
  return [
    world.craft + way * 0.42,
    world.craft - way * 0.2 + side * 0.22,
    world.craft - way * 0.2 - side * 0.22,
  ];
}

/// Lets go pointed at where the next well will be by the time the craft
/// arrives, which is what a player who has learnt the game does. The same rule
/// the playability test plays by.
bool _aimed(World world) {
  if (!world.isHeld) return false;
  final here = world.wells[world.heldBy!];
  Well? target;
  for (final well in world.wells) {
    if (well.at.y > here.at.y + 0.5) {
      target = well;
      break;
    }
  }
  if (target == null) return false;
  final flight = (target.at - world.craft).length / World.launchSpeed;
  final lead = Vec(
    target.at.x,
    target.at.y + 0.5 * World.gravity * flight * flight,
  );
  final want = (lead - world.craft).normalised;
  final going = world.velocity.normalised;
  return want.x * going.x + want.y * going.y > 0.995;
}
