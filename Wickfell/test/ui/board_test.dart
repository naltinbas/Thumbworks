import 'package:flutter_test/flutter_test.dart';
import 'package:wickfell/lamps/levels.dart';
import 'package:wickfell/lamps/solve.dart';
import 'package:wickfell/ui/board_screen.dart';
import 'package:wickfell/ui/title_screen.dart';

import '../support/lamps.dart';

void main() {
  group('getting in', () {
    testWidgets('the list shows every board and its size', (tester) async {
      await open(tester);
      expect(find.byType(TitleScreen), findsOne);
      for (final level in Levels.all) {
        expect(find.text(level.name), findsOne);
      }
      expect(find.text('${Levels.count} boards'), findsOne);
    });

    testWidgets('and a board opens when its row is tapped', (tester) async {
      await open(tester);
      await press(tester, 'Sixteen');

      expect(find.byType(BoardScreen), findsOne);
      expect(state(tester).level.name, 'Sixteen');
    });

    testWidgets('a board starts lit, with nothing pressed', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.board, Levels.at(0).lit);
      expect(state(tester).play.pressed, 0);
      expect(find.text('0 / ${Levels.at(0).presses}'), findsOne);
      expect(find.text('${Levels.at(0).presses} to go'), findsOne);
    });
  });

  group('pressing a lamp', () {
    testWidgets('turns it and the ones it touches', (tester) async {
      await open(tester, which: 0);
      final was = state(tester).play.board;

      await pressLamp(tester, 4);
      expect(state(tester).play.board,
          Levels.at(0).grid.pressed(was, 4));
      expect(state(tester).play.pressed, 1);
    });

    testWidgets('and pressing it again puts it back', (tester) async {
      await open(tester, which: 0);
      final was = state(tester).play.board;

      await pressLamp(tester, 0);
      await pressLamp(tester, 0);
      expect(state(tester).play.board, was);
      expect(state(tester).play.pressed, 2,
          reason: 'it still cost two presses');
    });

    testWidgets('takes a press back, and starts over', (tester) async {
      await open(tester, which: 0);
      await pressLamp(tester, 1);
      await pressLamp(tester, 2);

      await press(tester, 'Take back');
      expect(state(tester).play.pressed, 1);

      await press(tester, 'Again');
      expect(state(tester).play.pressed, 0);
      expect(state(tester).play.board, Levels.at(0).lit);
    });
  });

  group('wandering off', () {
    testWidgets('is said at once, not five presses later', (tester) async {
      await open(tester, which: 0);
      final wanted =
          Sums(Levels.at(0).grid).answer(Levels.at(0).lit).presses.toSet();
      final wrong = List.generate(Levels.at(0).lamps, (at) => at)
          .firstWhere((at) => !wanted.contains(at));

      await pressLamp(tester, wrong);
      expect(state(tester).play.onShortest, isFalse);
      expect(state(tester).saying, contains('not on any shortest way'));
      expect(find.textContaining('more than it had to be'), findsOne);
    });

    testWidgets('and taking the press back puts it right', (tester) async {
      await open(tester, which: 0);
      final wanted =
          Sums(Levels.at(0).grid).answer(Levels.at(0).lit).presses.toSet();
      final wrong = List.generate(Levels.at(0).lamps, (at) => at)
          .firstWhere((at) => !wanted.contains(at));

      await pressLamp(tester, wrong);
      await press(tester, 'Take back');
      expect(state(tester).play.onShortest, isTrue);
      expect(state(tester).saying, isNull);
    });
  });

  group('being shown', () {
    testWidgets('points at a lamp and says how many are left', (tester) async {
      await open(tester, which: 6);
      await press(tester, 'Show me');

      expect(state(tester).pointing, isNot(-1));
      expect(state(tester).saying, contains('From here it takes'));
      expect(state(tester).pointing, state(tester).play.nextPress);
    });

    testWidgets('and puts every board out in its own number of presses',
        (tester) async {
      // The claim the game is sold on, made through the screen.
      for (var which = 0; which < Levels.count; which++) {
        await open(tester, which: which);
        await putItOut(tester);

        final level = Levels.at(which);
        expect(state(tester).play.isDone, isTrue,
            reason: '${level.name} was not put out');
        expect(state(tester).play.pressed, level.presses,
            reason: '${level.name} took more presses than it had to');
        expect(find.text('Not a press wasted'), findsOne);
      }
    });
  });

  group('finishing', () {
    testWidgets('the long way says how much longer', (tester) async {
      await open(tester, which: 0);
      // Two presses that undo each other, then the way through.
      await pressLamp(tester, 0);
      await pressLamp(tester, 0);
      await putItOut(tester);

      expect(state(tester).play.isDone, isTrue);
      expect(state(tester).play.pressed, Levels.at(0).presses + 2);
      expect(find.text('All out'), findsOne);
      expect(find.textContaining('more than it had to be'), findsOne);
    });

    testWidgets('and the next one opens after it', (tester) async {
      await open(tester, which: 0);
      await putItOut(tester);

      await press(tester, 'The next one');
      expect(state(tester).level.name, Levels.at(1).name);
      expect(state(tester).play.pressed, 0);
    });

    testWidgets('the last one leads back to the list', (tester) async {
      await open(tester, which: Levels.count - 1);
      await putItOut(tester);

      await press(tester, 'The next one');
      expect(find.byType(TitleScreen), findsOne);
    });
  });
}
