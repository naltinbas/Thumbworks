import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slingwell/best_run.dart';
import 'package:slingwell/ui/app.dart';
import 'package:slingwell/ui/game_loop.dart';
import 'package:slingwell/ui/game_screen.dart';
import 'package:slingwell/ui/game_view.dart';
import 'package:slingwell/ui/hud.dart';

/// A best score as it would be on disk at the start of a session.
Future<BestRun> _saved([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(values));
  return BestRun(await SharedPreferences.getInstance());
}

/// Opens the game on a phone-shaped screen, on a seed of the test's choosing
/// so the same run happens every time.
///
/// One frame, and never a settle: the view asks for another frame forever, the
/// way a game does. The ticker's first tick is always worth nothing, so the
/// run has not moved yet when this returns.
Future<void> _open(WidgetTester tester, BestRun best, {int seed = 3}) async {
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: SlingwellApp.theme,
      home: GameScreen(best: best, seeds: () => seed),
    ),
  );
  await tester.pump();
}

GameLoop _loop(WidgetTester tester) =>
    tester.widget<GameView>(find.byType(GameView)).loop;

/// Somewhere in the middle of the glass, which is a thumb during a run and
/// nothing in particular on a card.
const _thumb = Offset(195, 500);

bool _isOver(WidgetTester tester) => tester.any(find.text('Go again'));

/// Plays the way someone who has never seen the game plays: let go the moment
/// anything catches. It ends a run in a couple of seconds.
Future<void> _mashUntilOver(WidgetTester tester) async {
  for (var frame = 0; frame < 900; frame++) {
    if (_isOver(tester)) return;
    await tester.tapAt(_thumb);
    await tester.pump(const Duration(milliseconds: 16));
  }
  fail('the run never ended');
}

/// Long enough for the card at the end of a run to finish arriving, after
/// which it starts taking taps.
Future<void> _cardArrives(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 500));

void main() {
  testWidgets('the game opens on its title', (tester) async {
    await _open(tester, await _saved());

    expect(find.text('Slingwell'), findsOneWidget);
    expect(find.text('Tap to fly'), findsOneWidget);
    expect(find.byType(Hud), findsNothing);
  });

  testWidgets('the craft is already swinging behind the title', (tester) async {
    await _open(tester, await _saved());

    await tester.pump(const Duration(milliseconds: 250));

    // The world runs under the title screen, so the first thing a player sees
    // is the game being played rather than a picture of it.
    expect(_loop(tester).world.steps, 30);
    expect(_loop(tester).world.isHeld, isTrue);
  });

  testWidgets('the title holds the world up above its own words', (
    tester,
  ) async {
    await _open(tester, await _saved());
    await tester.pump(const Duration(milliseconds: 250));

    // The craft swinging behind the title is half of what makes it look like
    // a game, and the first well is where the words are, so the world is
    // lifted while they are up.
    final lifted = _loop(tester);
    expect(lifted.focusY, lessThan(lifted.world.cameraY - 5));

    await tester.tapAt(_thumb);
    for (var frame = 0; frame < 200; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    // And settles back where a run is played, without the player having been
    // shown the world jumping.
    expect(_loop(tester).focusY, _loop(tester).world.cameraY);
  });

  testWidgets('the title says there is nothing to beat yet', (tester) async {
    await _open(tester, await _saved());

    expect(find.text('no best yet'), findsOneWidget);
  });

  testWidgets('the title shows the best score and the seed it happened on', (
    tester,
  ) async {
    await _open(
      tester,
      await _saved({'best.score': 42, 'best.seed': 777}),
    );

    expect(find.text('best 42 wells on seed 777'), findsOneWidget);
  });

  testWidgets('tapping the title starts a run and puts the score up', (
    tester,
  ) async {
    await _open(tester, await _saved());

    await tester.tapAt(_thumb);
    await tester.pump();

    expect(find.text('Slingwell'), findsNothing);
    expect(find.byType(Hud), findsOneWidget);
    expect(find.text('wells'), findsOneWidget);
    expect(find.text('metres up'), findsOneWidget);
  });

  testWidgets('the tap that starts a run is not a release', (tester) async {
    await _open(tester, await _saved());

    await tester.tapAt(_thumb);
    await tester.pump(const Duration(milliseconds: 100));

    // Starting and letting go are two different things to say, and a player
    // who has just started should still be holding on.
    expect(_loop(tester).world.isHeld, isTrue);
    expect(_loop(tester).replay.taps, isEmpty);
  });

  testWidgets('the score and the height on screen are the run being played', (
    tester,
  ) async {
    await _open(tester, await _saved());
    await tester.tapAt(_thumb);
    await tester.pump();

    for (var frame = 0;
        frame < 200 && _loop(tester).world.score == 0;
        frame++) {
      await tester.tapAt(_thumb);
      await tester.pump(const Duration(milliseconds: 16));
    }

    final world = _loop(tester).world;
    expect(world.score, greaterThan(0), reason: 'expected to catch a well');
    expect(world.cameraY, greaterThan(1));
    expect(find.text('${world.score}'), findsOneWidget);
    expect(find.text('${world.cameraY.round()}'), findsOneWidget);
  });

  testWidgets('a run that ends shows what it was worth and a way back in', (
    tester,
  ) async {
    await _open(tester, await _saved());
    await tester.tapAt(_thumb);
    await tester.pump();

    await _mashUntilOver(tester);

    expect(find.text('Adrift'), findsOneWidget);
    expect(find.text('Go again'), findsOneWidget);
    expect(find.byType(Hud), findsNothing);
    expect(find.text('this run was seed 3'), findsOneWidget);
  });

  testWidgets('the card at the end refuses the taps already on their way', (
    tester,
  ) async {
    await _open(tester, await _saved());
    await tester.tapAt(_thumb);
    await tester.pump();
    await _mashUntilOver(tester);

    // A player mashing at a well is still mashing a tenth of a second after
    // the run ends, and none of it should start the next one.
    await tester.tapAt(_thumb);
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.text('Go again'), findsOneWidget);
  });

  testWidgets('tapping the card once it has arrived starts the next run', (
    tester,
  ) async {
    await _open(tester, await _saved());
    await tester.tapAt(_thumb);
    await tester.pump();
    await _mashUntilOver(tester);
    await _cardArrives(tester);

    await tester.tapAt(_thumb);
    await tester.pump();

    expect(find.text('Go again'), findsNothing);
    expect(find.byType(Hud), findsOneWidget);
  });

  testWidgets('going again starts a fresh run with no menu on the way', (
    tester,
  ) async {
    await _open(tester, await _saved());
    await tester.tapAt(_thumb);
    await tester.pump();
    await _mashUntilOver(tester);
    await _cardArrives(tester);

    await tester.tap(find.text('Go again'));
    await tester.pump();

    expect(find.text('Slingwell'), findsNothing, reason: 'no trip through the title');
    expect(find.text('Go again'), findsNothing);
    expect(find.byType(Hud), findsOneWidget);
    expect(_loop(tester).world.score, 0);
    expect(_loop(tester).world.isOver, isFalse);
    expect(_loop(tester).world.steps, 0);
  });

  testWidgets('a run that beats the best is kept, with the seed it was on', (
    tester,
  ) async {
    final best = await _saved();
    await _open(tester, best, seed: 4711);
    await tester.tapAt(_thumb);
    await tester.pump();

    await _mashUntilOver(tester);
    final scored = _loop(tester).world.score;
    expect(scored, greaterThan(0), reason: 'a run worth recording');

    expect(find.text('New best'), findsOneWidget);
    expect(best.score, scored);
    expect(best.seed, 4711);
  });

  testWidgets('a run that does not beat the best leaves it alone', (
    tester,
  ) async {
    final best = await _saved({'best.score': 99, 'best.seed': 12});
    await _open(tester, best);
    await tester.tapAt(_thumb);
    await tester.pump();

    await _mashUntilOver(tester);

    expect(find.text('New best'), findsNothing);
    expect(find.text('best 99 wells on seed 12'), findsOneWidget);
    expect(best.score, 99);
    expect(best.seed, 12);
  });

  testWidgets('the best a run set is what the next run is playing against', (
    tester,
  ) async {
    final best = await _saved();
    await _open(tester, best);
    await tester.tapAt(_thumb);
    await tester.pump();
    await _mashUntilOver(tester);
    await _cardArrives(tester);
    final record = best.score;

    await tester.tap(find.text('Go again'));
    await tester.pump();
    // The score to beat is on the glass during the run, and on the card after
    // it, without the app having been started again in between.
    expect(find.text('best $record'), findsOneWidget);

    await _mashUntilOver(tester);
    expect(find.text('best $record wells on seed 3'), findsOneWidget);
  });

  testWidgets('the one word the player has to press is in the game\'s own face', (
    tester,
  ) async {
    // A whole TextStyle handed to styleFrom replaces the theme's label style
    // rather than merging into it, so a style written from nothing carries no
    // family and the button ends up in whatever face the platform hands out.
    final theme = SlingwellApp.theme;
    final button = theme.filledButtonTheme.style!.textStyle!
        .resolve(<WidgetState>{});

    expect(button?.fontFamily, isNotNull);
    expect(button?.fontFamily, theme.textTheme.labelLarge?.fontFamily);
  });

  testWidgets('the app opens the game on the best score it was handed', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      SlingwellApp(best: await _saved({'best.score': 8, 'best.seed': 21})),
    );
    await tester.pump();

    expect(find.text('Slingwell'), findsOneWidget);
    expect(find.text('best 8 wells on seed 21'), findsOneWidget);
  });
}
