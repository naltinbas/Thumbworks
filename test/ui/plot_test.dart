import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinderplot/game/play.dart';
import 'package:cinderplot/game/plots.dart';
import 'package:cinderplot/ui/plot_screen.dart';
import 'package:cinderplot/ui/title_screen.dart';

import '../support/plot.dart';

void main() {
  group('getting in', () {
    testWidgets('opens on the plots', (tester) async {
      await open(tester);
      expect(find.byType(TitleScreen), findsOne);
      for (final plot in Plots.all) {
        expect(find.text(plot.name), findsOne);
      }
    });

    testWidgets('a plot opens when its row is tapped', (tester) async {
      await open(tester);
      await tester.tap(find.text('The commons'));
      await tester.pump();

      expect(find.byType(PlotScreen), findsOne);
      expect(state(tester).plot.name, 'The commons');
    });

    testWidgets('and going back leaves it', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      expect(find.byType(TitleScreen), findsOne);
    });

    testWidgets('the board arrives with a region already open', (tester) async {
      // The first tap of a minefield is normally a coin toss. Here the square
      // the proof starts from is open before anybody touches it.
      await open(tester, which: 0);
      final play = state(tester).play;

      expect(play.opened.length, greaterThan(3));
      expect(play.moves, 0);
      expect(play.ending, Ending.going);
      expect(find.text('0:00'), findsOne);
    });
  });

  group('digging', () {
    testWidgets('a tap opens a square', (tester) async {
      await open(tester, which: 0);
      final at = aSafeShutSquare(tester);

      await tapSquare(tester, at);
      expect(state(tester).play.isOpen(at), isTrue);
    });

    testWidgets('a long press plants a flag, and counts one off',
        (tester) async {
      await open(tester, which: 0);
      final was = state(tester).play.minesLeft;
      final at = aSafeShutSquare(tester);

      await holdSquare(tester, at);
      expect(state(tester).play.isFlagged(at), isTrue);
      expect(state(tester).play.minesLeft, was - 1);

      await holdSquare(tester, at);
      expect(state(tester).play.isFlagged(at), isFalse,
          reason: 'holding it again takes the flag off');
    });

    testWidgets('flagging mode swaps what a tap and a hold do', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Opening');
      expect(state(tester).flagging, isTrue);
      expect(find.text('Flagging'), findsOne);

      final at = aSafeShutSquare(tester);
      await tapSquare(tester, at);
      expect(state(tester).play.isFlagged(at), isTrue);
    });

    testWidgets('a mine ends it, and the rest of them are shown',
        (tester) async {
      await open(tester, which: 0);
      await tapSquare(tester, aMine(tester));

      expect(state(tester).play.ending, Ending.blown);
      expect(find.text('Gone up'), findsOne);
      expect(find.text('Another one'), findsOne);
    });

    testWidgets('and nothing happens after that', (tester) async {
      await open(tester, which: 0);
      await tapSquare(tester, aMine(tester));
      final was = state(tester).play.opened.length;

      await tapSquare(tester, aSafeShutSquare(tester));
      expect(state(tester).play.opened.length, was);
    });

    testWidgets('the clock runs while the board is going, and stops after',
        (tester) async {
      await open(tester, which: 0);
      await tester.pump(const Duration(seconds: 3));
      expect(state(tester).seconds, 3);
      expect(find.text('0:03'), findsOne);

      await tapSquare(tester, aMine(tester));
      await tester.pump(const Duration(seconds: 5));
      expect(state(tester).seconds, 3, reason: 'the clock should have stopped');
    });
  });

  group('being told why', () {
    testWidgets('says a sentence and points at the numbers it read',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why?');

      final showing = state(tester).showing;
      expect(showing, isNotNull, reason: 'there is always something to say');
      expect(showing!.safe.isNotEmpty || showing.mined.isNotEmpty, isTrue);
      expect(find.text('Do it'), findsOne);
      expect(painterOf(tester).showing, same(showing));
    });

    testWidgets('and then does it when asked again', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why?');
      final showing = state(tester).showing!;

      await press(tester, 'Do it');
      for (final at in showing.safe) {
        expect(state(tester).play.isOpen(at), isTrue);
      }
      for (final at in showing.mined) {
        expect(state(tester).play.isFlagged(at), isTrue);
      }
      expect(state(tester).showing, isNull);
    });

    testWidgets('clears every plot, one answer at a time, without ever going up',
        (tester) async {
      // The promise of the game, made through the screen. Nothing here knows
      // where the mines are; it presses Why? and Do it until there is nothing
      // left, and a board that ever needed a guess would leave the button
      // with nothing to say.
      for (var which = 0; which < Plots.count; which++) {
        await open(tester, which: which);

        for (var turn = 0; turn < 500; turn++) {
          if (state(tester).play.isOver) break;
          await press(tester, 'Why?');
          expect(state(tester).showing, isNotNull,
              reason: '${Plots.at(which).name} ran out of things to prove '
                  'with ${state(tester).play.toGo} squares to go');
          await press(tester, 'Do it');
        }

        expect(state(tester).play.ending, Ending.cleared,
            reason: '${Plots.at(which).name} was not finished by reasoning');
        expect(find.text('Cleared'), findsOne);
      }
    });

    testWidgets('counts how many answers were asked for', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Why?');
      await press(tester, 'Do it');
      await press(tester, 'Why?');
      await press(tester, 'Do it');

      while (!state(tester).play.isOver) {
        await press(tester, 'Why?');
        await press(tester, 'Do it');
      }
      expect(find.textContaining('answers asked for'), findsOne);
    });
  });

  group('the board on the screen', () {
    testWidgets('keeps its squares square on every phone', (tester) async {
      const phones = [Size(960, 1704), Size(1170, 2532), Size(1440, 3120)];
      for (final screen in phones) {
        await open(tester, which: 2, screen: screen);
        final metrics = metricsOf(tester);
        expect(metrics.board.width / metrics.across,
            closeTo(metrics.board.height / metrics.down, 0.001));
      }
    });

    testWidgets('finds the square under a finger', (tester) async {
      await open(tester, which: 1);
      final metrics = metricsOf(tester);
      for (final at in [0, 5, 40, metrics.across * metrics.down - 1]) {
        expect(metrics.under(metrics.squareAt(at).center), at);
      }
      expect(metrics.under(const Offset(-20, -20)), isNull);
    });

    testWidgets('starts another board that is not the one just played',
        (tester) async {
      await open(tester, which: 0);
      final was = state(tester).play.field.mines;

      await tapSquare(tester, aMine(tester));
      await press(tester, 'Another one');

      expect(state(tester).play.ending, Ending.going);
      expect(state(tester).play.field.mines, isNot(was));
    });
  });
}
