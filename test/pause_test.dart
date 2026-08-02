import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/game/lexicon.dart';
import 'package:latchword/best_score.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latchword/ui/away_cover.dart';
import 'package:latchword/ui/board_view.dart';
import 'package:latchword/ui/game_screen.dart';
import 'package:latchword/ui/hud.dart';
import 'package:latchword/ui/summary_card.dart';

/// Tells the app it is going away, the way the system does.
///
/// One state at a time, because a phone does not jump: it takes the app
/// through inactive and hidden on the way to paused, and the framework
/// refuses a transition that skips a step.
Future<void> _leave(WidgetTester tester) async {
  for (final state in const [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
    await tester.pump();
  }
}

/// And that it is back on screen.
Future<void> _return(WidgetTester tester) async {
  for (final state in const [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
    await tester.pump();
  }
}

void main() {
  // A round has to survive a phone call, and it must not hand a player a way
  // to stop the clock and study the board. These two tests are the two halves
  // of that, and changing either behaviour should fail one of them.
  group('leaving the game mid round', () {
    Future<void> startARound(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final best = BestScore(await SharedPreferences.getInstance());
      await tester.pumpWidget(MaterialApp(
        home: GameScreen(
          lexicon: Lexicon.standard(),
          best: best,
          seeds: () => 7,
        ),
      ));
      await tester.tap(find.text('Play'));
      // Pumped rather than settled: the round's clock is an animation, and
      // settling would sit here running it until the round was over.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    /// What the clock on the HUD is reading, as m:ss.
    String clockFace(WidgetTester tester) => tester
        .widgetList<Text>(find.descendant(
          of: find.byType(Hud),
          matching: find.byType(Text),
        ))
        .map((text) => text.data ?? '')
        .firstWhere((face) => RegExp(r'^\d+:\d\d$').hasMatch(face));

    testWidgets('stops the clock rather than costing the round', (tester) async {
      await startARound(tester);
      await tester.pump(const Duration(seconds: 10));
      final left = clockFace(tester);

      await _leave(tester);
      // A long time passes with the game off screen: longer than the round
      // itself, so a clock that kept running would have ended it.
      await tester.pump(const Duration(minutes: 3));
      await _return(tester);
      await tester.pump();

      expect(clockFace(tester), left,
          reason: 'the clock should read what it did when the player left');
      expect(find.byType(SummaryCard), findsNothing,
          reason: 'the round should not have ended while away');
    });

    testWidgets('covers the board so the pause shows nothing', (tester) async {
      await startARound(tester);
      await _leave(tester);
      await _return(tester);

      expect(find.byType(AwayCover), findsOneWidget);
      expect(find.text('Paused'), findsOneWidget);

      // Opaque, not a dark wash. Letters on a near-black board under a
      // ninety-per-cent scrim are still letters, and a cover that can be read
      // through is a board being studied on a stopped clock.
      final cover = tester.widget<ColoredBox>(find.descendant(
        of: find.byType(AwayCover),
        matching: find.byType(ColoredBox),
      ));
      expect(cover.color.a, 1.0);

      // The board is behind the cover and cannot be traced on.
      final blocked = tester.widget<IgnorePointer>(
        find.ancestor(
          of: find.byType(BoardView),
          matching: find.byType(IgnorePointer),
        ).first,
      );
      expect(blocked.ignoring, isTrue);
    });

    testWidgets('carries on where it left off when tapped', (tester) async {
      await startARound(tester);
      await _leave(tester);
      await _return(tester);
      expect(find.byType(AwayCover), findsOneWidget);

      await tester.tap(find.byType(AwayCover));
      await tester.pump();

      expect(find.byType(AwayCover), findsNothing);
      expect(find.byType(BoardView), findsOneWidget);
    });
  });
}
