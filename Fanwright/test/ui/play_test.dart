import 'package:flutter/material.dart' hide Card, Table;
import 'package:flutter_test/flutter_test.dart';
import 'package:fanwright/game/book.dart';
import 'package:fanwright/game/cards.dart';
import 'package:fanwright/game/game.dart';
import 'package:fanwright/game/solver.dart';
import 'package:fanwright/game/table.dart';
import 'package:fanwright/ui/game_screen.dart';
import 'package:fanwright/ui/title_screen.dart';
import 'package:fanwright/ui/won_card.dart';

import '../support/playing.dart';

void main() {
  group('the title', () {
    testWidgets('says the promise and deals the first one', (tester) async {
      await open(tester, playing: false);

      expect(find.text('Fanwright'), findsOneWidget);
      expect(find.text('Every deal in here can be won'), findsOneWidget);
      expect(find.textContaining('${Book.count} of them'), findsOneWidget);
      expect(find.text('Deal ${Book.at(0)}'), findsOneWidget);
      expect(find.byType(GameScreen), findsNothing);

      await tester.ensureVisible(find.text('Deal ${Book.at(0)}'));
      await tester.pump();
      await tester.tap(find.text('Deal ${Book.at(0)}'));
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(TitleScreen), findsNothing);
    });

    testWidgets('steps to another deal', (tester) async {
      await open(tester, playing: false);
      expect(find.text('the first one'), findsOneWidget);

      await tester.ensureVisible(find.bySemanticsLabel('The deal after'));
      await tester.tap(find.bySemanticsLabel('The deal after'));
      await tester.pump();

      expect(find.text('Deal ${Book.at(1)}'), findsOneWidget);
      expect(find.text('number 2 in the book'), findsOneWidget);
    });
  });

  group('tapping a card', () {
    testWidgets('sends an ace home', (tester) async {
      // A hand with an ace on the end of a column and nothing else to do.
      await open(tester, at: Game.at(Table.of(columns: const [
        'KD AS',
        '2H',
        '3C',
        '4C',
        '5C',
        '9C',
        '7C',
        '8C',
      ])));

      expect(table(tester).home(Suit.spades), 0);
      await tapColumn(tester, 0);

      expect(table(tester).home(Suit.spades), 1);
      expect(table(tester).column(0), [Card.from('KD')]);
    });

    testWidgets('and the two behind it goes on its own', (tester) async {
      // Tidying is automatic and safe: a two never has to wait for anything.
      await open(tester, at: Game.at(Table.of(columns: const [
        'KD AS',
        '2S',
        '3C',
        '4C',
        '5C',
        '9C',
        '7C',
        '8C',
      ])));

      await tapColumn(tester, 0);
      expect(table(tester).home(Suit.spades), 2);
    });

    testWidgets('moves a run when the run is tapped', (tester) async {
      await open(tester, at: Game.at(Table.of(columns: const [
        'KS QH JS',
        'KC',
        '3D',
        '3C',
        '3H',
        '3S',
        '4D',
        '4C',
      ])));

      // The queen, one card up from the end.
      await tapColumn(tester, 0, card: 1);

      expect(table(tester).column(1), [
        Card.from('KC'),
        Card.from('QH'),
        Card.from('JS'),
      ]);
      expect(table(tester).column(0), [Card.from('KS')]);
    });

    testWidgets('does nothing when the card has nowhere to go',
        (tester) async {
      await open(tester, at: Game.at(stuckTable));
      final was = table(tester).fingerprint;

      await tapColumn(tester, 0);
      await tapCell(tester, 0);

      expect(table(tester).fingerprint, was);
      expect(screenState(tester).game.moves, 0);
    });
  });

  group('undo', () {
    testWidgets('puts the card back', (tester) async {
      await open(tester, at: Game.at(Table.of(columns: const [
        'KD 5H',
        '2S',
        '3C',
        '4C',
        '5C',
        '9C',
        '7C',
        '8C',
      ])));
      final was = table(tester).fingerprint;

      await tapColumn(tester, 0);
      expect(table(tester).fingerprint, isNot(was));

      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(table(tester).fingerprint, was);
    });

    testWidgets('is dead before anything has been played', (tester) async {
      await open(tester);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(screenState(tester).game.moves, 0);
    });
  });

  group('the hint', () {
    testWidgets('rounds a card and where it is going', (tester) async {
      await open(tester);
      expect(painterOf(tester).lit, isEmpty);

      await tester.tap(find.text('Hint'));
      await settle(tester);

      expect(painterOf(tester).lit, hasLength(2),
          reason: 'the card to pick up and where to put it');
    });

    testWidgets('says so when there is no way on', (tester) async {
      await open(tester, at: Game.at(stuckTable));

      await tester.tap(find.text('Hint'));
      await settle(tester);

      expect(find.text('No way on'), findsOneWidget);
      expect(painterOf(tester).lit, isEmpty);
    });
  });

  group('winning', () {
    testWidgets('says so, and offers the next deal', (tester) async {
      // One card from home, so the tap that finishes it is the test.
      await open(tester, at: Game.at(
        Table.of(
          columns: const ['KS', '', '', '', '', '', '', ''],
          homes: const [13, 13, 13, 12],
        ),
      ));

      await tapColumn(tester, 0);
      await tester.pump();

      expect(table(tester).isWon, isTrue);
      expect(find.byType(WonCard), findsOneWidget);
      expect(find.text('Out'), findsOneWidget);
      expect(find.text('Next deal'), findsOneWidget);
    });

    testWidgets('a whole deal, played by taking every hint', (tester) async {
      // The longest test here and the one worth having: it plays a real deal
      // to the end through the screen, by tapping Hint and then tapping
      // whatever it points at.
      await open(tester);

      var taken = 0;
      while (!table(tester).isWon && taken < 200) {
        await tester.tap(find.text('Hint'));
        await settle(tester);

        final lit = painterOf(tester).lit;
        if (lit.isEmpty) break;
        final from = lit.first;
        if (from.where == Where.cell) {
          await tapCell(tester, from.at);
        } else {
          await tapColumn(tester, from.at, card: from.card);
        }
        taken++;
      }

      expect(table(tester).isWon, isTrue, reason: 'stopped after $taken hints');
      expect(find.byType(WonCard), findsOneWidget);
    });
  });

  group('fitting a phone', () {
    for (final entry in const {
      'iphone-se': Size(320, 568),
      'iphone-14': Size(390, 844),
      'pixel-7': Size(412, 915),
    }.entries) {
      testWidgets('the table fits and is playable on ${entry.key}',
          (tester) async {
        await open(tester, screen: entry.value * 3);

        final metrics = metricsOf(tester);
        expect(metrics.cardWidth, greaterThan(30),
            reason: 'a card a thumb can hit');

        // The longest column has to fit above the buttons.
        final longest = [
          for (var at = 0; at < Table.columnCount; at++)
            table(tester).column(at).length,
        ].reduce((a, b) => a > b ? a : b);
        final bottom = metrics.columnsTop +
            metrics.stepFor(longest) * (longest - 1) +
            metrics.cardHeight;
        expect(bottom, lessThanOrEqualTo(metrics.space.height + 0.5));

        // And a tap still lands where it was aimed.
        final move = const Solver().solve(table(tester));
        expect(move.won, isTrue);
      });
    }
  });
}
