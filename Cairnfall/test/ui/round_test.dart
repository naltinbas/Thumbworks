import 'package:flutter_test/flutter_test.dart';
import 'package:cairnfall/stones/cairn.dart';
import 'package:cairnfall/stones/play.dart';
import 'package:cairnfall/stones/rounds.dart';
import 'package:cairnfall/ui/app.dart';
import 'package:cairnfall/ui/round_screen.dart';
import 'package:cairnfall/ui/title_screen.dart';

import '../support/table.dart';

void main() {
  group('getting in', () {
    testWidgets('the list shows every round and what it is for',
        (tester) async {
      await open(tester);
      expect(find.byType(TitleScreen), findsOne);
      for (final round in Rounds.all) {
        expect(find.text(round.name), findsOne);
        expect(find.text(round.about), findsOne);
      }
      expect(find.text('${Rounds.count} rounds'), findsOne);
    });

    testWidgets('and a round opens when its row is tapped', (tester) async {
      await open(tester);
      await tester.tap(find.text('Two heaps'));
      await tester.pump();

      expect(find.byType(RoundScreen), findsOne);
      expect(state(tester).round.name, 'Two heaps');
    });

    testWidgets('a round starts with its cairns and your move', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.cairns, Rounds.at(0).cairns);
      expect(state(tester).play.toMove, Who.you);
      expect(find.text('your move'), findsOne);
    });

    testWidgets('and every one of them can be won from where it starts',
        (tester) async {
      // The promise on the list. A round worth nothing is one where nothing
      // the player does matters, and there is not one of those here.
      for (final round in Rounds.all) {
        expect(CairnfallApp.worth.ofAll(round.cairns), isNot(0),
            reason: '${round.name} is lost before it starts');
      }
    });
  });

  group('taking stones', () {
    testWidgets('a cairn has to be picked before anything can come off it',
        (tester) async {
      await open(tester, which: 0);
      expect(find.text('Tap a cairn to take from it.'), findsOne);

      await pickCairn(tester, 0);
      expect(state(tester).picked, 0);
      expect(find.text('Take as many as you like.'), findsOne);
    });

    testWidgets('and then they come off it', (tester) async {
      await open(tester, which: 0);
      await takeFrom(tester, 0, 2);

      expect(state(tester).play.cairns[0].stones,
          Rounds.at(0).cairns[0].stones - 2);
      expect(state(tester).picked, -1);
    });

    testWidgets('a short cairn offers one, two or three and no more',
        (tester) async {
      await open(tester, which: 2);
      final short = cairnWith(tester, Rule.three);
      await pickCairn(tester, short);

      expect(find.bySemanticsLabel('take 1'), findsOne);
      expect(find.bySemanticsLabel('take 3'), findsOne);
      expect(find.bySemanticsLabel('take 4'), findsNothing);
    });

    testWidgets('a halving cairn offers one stone or half of them',
        (tester) async {
      await open(tester, which: 4);
      final halves = cairnWith(tester, Rule.halves);
      final stones = state(tester).play.cairns[halves].stones;
      await pickCairn(tester, halves);

      expect(find.bySemanticsLabel('take 1'), findsOne);
      expect(find.bySemanticsLabel('take ${stones ~/ 2}'), findsOne);
      expect(find.bySemanticsLabel('take 2'), findsNothing,
          reason: 'two is neither one nor half of twelve');
    });
  });

  group('the other player', () {
    testWidgets('moves after a moment, and never gives the round away',
        (tester) async {
      await open(tester, which: 0);
      // Throw it away on purpose: take one off a cairn that leaves them a
      // winning position.
      await takeFrom(tester, 0, 1);
      expect(state(tester).theirs, isTrue);
      expect(state(tester).wrong, 1, reason: 'and the game noticed');

      await letThemMove(tester);
      expect(state(tester).theirs, isFalse);
      expect(CairnfallApp.worth.ofAll(state(tester).play.cairns), 0,
          reason: 'they should have left nothing to be had');
    });

    testWidgets('and takes the last stone when it is offered', (tester) async {
      await open(tester, which: 0);
      // Every stone but two off the big cairn, then the small one: whatever
      // is left, they finish it.
      await takeFrom(tester, 0, 3);
      await letThemMove(tester);

      var guard = 0;
      while (!state(tester).play.isOver && guard++ < 40) {
        if (state(tester).theirs) {
          await letThemMove(tester);
          continue;
        }
        final play = state(tester).play;
        final at = play.cairns.indexWhere((cairn) => !cairn.isGone);
        await takeFrom(tester, at, play.cairns[at].takes.first);
      }
      expect(state(tester).play.isOver, isTrue);
      expect(state(tester).play.won, Who.them,
          reason: 'having thrown it away, it should be gone');
    });
  });

  group('the numbers on show', () {
    testWidgets('give every cairn a value and say what they come to',
        (tester) async {
      await open(tester, which: 0, showWorth: true);

      for (final cairn in Rounds.at(0).cairns) {
        expect(find.text('worth ${CairnfallApp.worth.of(cairn)}'), findsWidgets);
      }
      expect(
        find.text(
          'all of them together: ${CairnfallApp.worth.ofAll(Rounds.at(0).cairns)}',
        ),
        findsOne,
      );
    });

    testWidgets('and can be put away again', (tester) async {
      await open(tester, which: 0, showWorth: true);
      expect(find.textContaining('all of them together'), findsOne);

      await tester.tap(find.text('the numbers'));
      await tester.pump();
      expect(find.textContaining('all of them together'), findsNothing);
      expect(state(tester).showWorth, isFalse);
    });

    testWidgets('say nothing is left when the winning move has been made',
        (tester) async {
      await open(tester, which: 0, showWorth: true);
      final move = state(tester).play.bestMove(CairnfallApp.worth);
      await takeFrom(tester, move.cairn, move.stones);

      expect(find.text('all of them together: 0'), findsOne);
      expect(state(tester).wrong, 0);
    });
  });

  group('a whole round', () {
    testWidgets('played by the arithmetic is won, and nothing given away',
        (tester) async {
      // The claim the game is sold on, made through the screen: every round
      // starts winnable, so playing the winning move every time has to win.
      for (var which = 0; which < Rounds.count; which++) {
        await open(tester, which: which);
        await playItOut(tester);

        expect(state(tester).play.isOver, isTrue,
            reason: '${Rounds.at(which).name} never finished');
        expect(state(tester).play.won, Who.you,
            reason: '${Rounds.at(which).name} was lost by perfect play');
        expect(state(tester).wrong, 0);
        expect(find.text('The last stone'), findsOne);
      }
    });

    testWidgets('and the next one opens after it', (tester) async {
      await open(tester, which: 0);
      await playItOut(tester);

      await press(tester, 'The next one');
      expect(state(tester).round.name, Rounds.at(1).name);
      expect(state(tester).play.cairns, Rounds.at(1).cairns);
    });

    testWidgets('the last one leads back to the list', (tester) async {
      await open(tester, which: Rounds.count - 1);
      await playItOut(tester);

      await press(tester, 'The next one');
      expect(find.byType(TitleScreen), findsOne);
    });
  });
}
