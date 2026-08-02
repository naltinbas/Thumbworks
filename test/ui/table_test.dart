import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazardwell/game/odds.dart';
import 'package:hazardwell/game/play.dart';
import 'package:hazardwell/game/rules.dart';
import 'package:hazardwell/ui/table_screen.dart';
import 'package:hazardwell/ui/title_screen.dart';

import '../support/table.dart';

void main() {
  late Odds odds;

  setUpAll(() => odds = Odds.reckon());

  group('getting in', () {
    testWidgets('the way in says the rules and what the house has done',
        (tester) async {
      await open(tester, odds: odds, atTable: false);

      expect(find.byType(TitleScreen), findsOne);
      expect(find.text('Hazardwell'), findsOne);
      expect(find.text('The house has worked the whole game out'), findsOne);
      expect(find.textContaining('settled in'), findsOne);
    });

    testWidgets('and sitting down deals a game at nothing all', (tester) async {
      await open(tester, odds: odds, atTable: false);
      await press(tester, 'Take a seat');

      expect(find.byType(TableScreen), findsOne);
      expect(state(tester).play.yours, 0);
      expect(state(tester).play.theirs, 0);
      expect(state(tester).play.toMove, Who.you);
    });
  });

  group('a throw', () {
    testWidgets('with one die adds what it shows', (tester) async {
      await open(tester, odds: odds, dice: Loaded([5]));
      await press(tester, 'One die');

      expect(state(tester).play.turn, 5);
      expect(find.text('5'), findsWidgets);
      expect(state(tester).said, contains('threw a 5'));
    });

    testWidgets('with two dice pays both, and double for a pair',
        (tester) async {
      await open(tester, odds: odds, dice: Loaded([4, 4]));
      await press(tester, 'Two dice');

      expect(state(tester).play.turn, 16, reason: 'a pair pays twice');
      expect(state(tester).said, contains('double'));
    });

    testWidgets('of a one hands the turn over', (tester) async {
      await open(tester, odds: odds, dice: Loaded([6, 1]));
      await press(tester, 'One die');
      expect(state(tester).play.turn, 6);

      await press(tester, 'One die');
      expect(state(tester).play.turn, 0);
      expect(state(tester).play.yours, 0);
      expect(state(tester).theirs, isTrue);
      expect(state(tester).said, contains('threw a one'));
    });

    testWidgets('of two ones takes the score with it', (tester) async {
      await open(
        tester,
        odds: odds,
        dice: Loaded([1]),
        from: const Play(yours: 40, theirs: 20, turn: 9, toMove: Who.you),
      );
      await press(tester, 'Two dice');

      expect(state(tester).play.yours, 0, reason: 'everything goes');
      expect(state(tester).play.turn, 0);
      expect(state(tester).said, contains('Everything goes'));
    });
  });

  group('banking', () {
    testWidgets('puts the turn in the score and hands over', (tester) async {
      await open(tester, odds: odds, dice: Loaded([6, 5]));
      await press(tester, 'One die');
      await press(tester, 'Bank 6');

      expect(state(tester).play.yours, 6);
      expect(state(tester).play.turn, 0);
      expect(state(tester).theirs, isTrue);
    });

    testWidgets('and there is nothing to bank at the start of a turn',
        (tester) async {
      await open(tester, odds: odds, dice: Loaded([5]));
      await press(tester, 'Bank 0');
      expect(state(tester).play.yours, 0,
          reason: 'the button should not have done anything');
      expect(state(tester).theirs, isFalse);
    });
  });

  group('the house', () {
    testWidgets('takes its turn after a moment, and plays the best move',
        (tester) async {
      // Handed a game where it is their throw and dice that always show a
      // six, so what it does is decided by the odds and nothing else.
      await open(
        tester,
        odds: odds,
        dice: Loaded([6]),
        from: const Play(yours: 30, theirs: 30, turn: 0, toMove: Who.them),
      );
      expect(state(tester).theirs, isTrue);
      expect(state(tester).play.turn, 0, reason: 'not yet');

      await tester.pump(const Duration(milliseconds: 900));
      expect(state(tester).play.turn, greaterThan(0));
    });

    testWidgets('and keeps going until it banks', (tester) async {
      await open(
        tester,
        odds: odds,
        dice: Loaded([6]),
        from: const Play(yours: 10, theirs: 10, turn: 0, toMove: Who.them),
      );
      await letThemPlay(tester);

      expect(state(tester).theirs, isFalse, reason: 'it should have banked');
      expect(state(tester).play.theirs, greaterThan(10));
      expect(state(tester).play.turn, 0);
    });

    testWidgets('banks when banking wins, rather than throwing again',
        (tester) async {
      const nearly = Play(yours: 20, theirs: 88, turn: 12, toMove: Who.them);
      expect(odds.bestAt(nearly.mine, nearly.others, nearly.turn), Move.bank);

      await open(tester, odds: odds, dice: Loaded([6]), from: nearly);
      await tester.pump(const Duration(milliseconds: 900));

      expect(state(tester).play.theirs, 100);
      expect(state(tester).play.won, Who.them);
    });
  });

  group('the scores', () {
    testWidgets('draw a bar that has a width', (tester) async {
      // A column that sizes its children to what they ask for gives a bar
      // made of flexible pieces no width at all, and it goes missing without
      // a word from anybody.
      await open(
        tester,
        odds: odds,
        from: const Play(yours: 62, theirs: 51, turn: 9, toMove: Who.you),
      );
      final bar = find.byType(ClipRRect);
      expect(bar, findsWidgets);
      for (final one in bar.evaluate()) {
        expect(tester.getSize(find.byWidget(one.widget)).width,
            greaterThan(60));
      }
    });
  });

  group('the odds on show', () {
    testWidgets('give a number to all three moves, and mark the best',
        (tester) async {
      await open(tester, odds: odds, showOdds: true);

      final chance = odds.chanceAt(0, 0, 0);
      for (final move in Move.values) {
        expect(
          find.text('${(chance.of(move) * 100).toStringAsFixed(1)}%'),
          findsOne,
          reason: 'the strip should say what ${move.name} is worth',
        );
      }
    });

    testWidgets('and can be put away again', (tester) async {
      await open(tester, odds: odds, showOdds: true);
      expect(find.text('bank'), findsOne);

      await tester.tap(find.text('the odds'));
      await tester.pump();
      expect(find.text('bank'), findsNothing);
      expect(state(tester).showOdds, isFalse);
    });
  });

  group('the end of a game', () {
    testWidgets('says who won and how many decisions were the best ones',
        (tester) async {
      await open(
        tester,
        odds: odds,
        dice: Loaded([6]),
        from: const Play(yours: 94, theirs: 40, turn: 0, toMove: Who.you),
      );
      await press(tester, 'One die');
      await press(tester, 'Bank 6');

      expect(state(tester).play.isOver, isTrue);
      expect(state(tester).play.won, Who.you);
      expect(find.text('You won'), findsOne);
      expect(find.text('100 to 40'), findsOne);
      expect(find.textContaining('decisions'), findsOne);
    });

    testWidgets('and says what a bad decision cost', (tester) async {
      await open(
        tester,
        odds: odds,
        dice: Loaded([6]),
        from: const Play(yours: 94, theirs: 40, turn: 0, toMove: Who.you),
      );
      // Rolling on at 94 with six in hand is throwing the game away, and the
      // review knows exactly how much of it.
      await press(tester, 'One die');
      await press(tester, 'Two dice');
      await press(tester, 'Bank 30');

      final review = state(tester).review;
      expect(review.mistakes, greaterThan(0));
      expect(review.given, greaterThan(0.001));
      expect(find.textContaining('% more'), findsWidgets);
    });

    testWidgets('and another game deals a fresh one', (tester) async {
      await open(
        tester,
        odds: odds,
        dice: Loaded([6]),
        from: const Play(yours: 94, theirs: 40, turn: 0, toMove: Who.you),
      );
      await press(tester, 'One die');
      await press(tester, 'Bank 6');
      await press(tester, 'Another game');

      expect(state(tester).play.yours, 0);
      expect(state(tester).play.theirs, 0);
      expect(state(tester).play.isOver, isFalse);
    });
  });

  group('a whole game', () {
    testWidgets('played by the odds ends with nothing given away',
        (tester) async {
      // Both sides playing the table's own advice. Whoever wins, the review
      // should find no mistake in it — which is the review checking itself
      // against the same numbers the house is playing by.
      await open(tester, odds: odds, dice: Loaded([3, 6, 2, 5, 4, 6, 2, 3]));

      for (var turn = 0; turn < 400; turn++) {
        if (state(tester).play.isOver) break;
        if (state(tester).theirs) {
          await tester.pump(const Duration(milliseconds: 900));
          continue;
        }
        final play = state(tester).play;
        final best = odds.bestAt(play.mine, play.others, play.turn);
        await press(tester, switch (best) {
          Move.bank => 'Bank ${play.turn}',
          Move.one => 'One die',
          Move.two => 'Two dice',
        });
      }

      expect(state(tester).play.isOver, isTrue, reason: 'it never finished');
      expect(state(tester).review.mistakes, 0);
      expect(state(tester).review.sharpness, 1);
      expect(find.textContaining('played it perfectly'), findsOne);
    });
  });
}
