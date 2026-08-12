import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tussockmere/best.dart';
import 'package:tussockmere/mere/fields.dart';

import '../support/mere.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a field opened', () {
    testWidgets('lays the marsh out and names the task',
        (tester) async {
      await open(tester, which: 0);
      expect(find.text('The Three Field'), findsOne);
      expect(find.text('0 steps'), findsOne);
      expect(find.text('link west to east, stepping first'), findsOne);
      expect(find.textContaining('Step a tussock'), findsOne);
    });

    testWidgets('a step is answered by the mere', (tester) async {
      await open(tester, which: 0);
      await tapTussock(tester, 4);
      final play = state(tester).play;
      expect(play.cells[4], 1);
      expect(play.cells.where((cell) => cell == 2), hasLength(1));
      expect(find.text('1 step'), findsOne);
    });

    testWidgets('a taken tussock is refused', (tester) async {
      await open(tester, which: 0);
      await tapTussock(tester, 4);
      await tapTussock(tester, 4);
      expect(state(tester).play.moves, 1);
      expect(find.text('That tussock is taken.'), findsOne);
    });

    testWidgets('a step that hands the marsh away is called out',
        (tester) async {
      await open(tester, which: 1);
      // Found, not guessed: a first step the solve then wins
      // against.
      final play = state(tester).play;
      int? wander;
      for (var at = 0; at < 16; at++) {
        final after = play.step(at);
        if (!after.isOver && after.standing != 1) {
          wander = at;
          break;
        }
      }
      expect(wander, isNotNull,
          reason: 'every opening keeps the four-field');
      await tapTussock(tester, wander!);
      expect(
        find.textContaining('handed the marsh away'),
        findsOne,
      );
    });

    testWidgets('Back steps out of both plies', (tester) async {
      await open(tester, which: 0);
      await tapTussock(tester, 4);
      await press(tester, 'Back');
      expect(state(tester).play.moves, 0);
      expect(state(tester).play.cells.where((cell) => cell != 0),
          isEmpty);
    });

    testWidgets('Show me points the solve\'s step', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(
        find.textContaining('the solve keeps the win through it'),
        findsOne,
      );
    });

    testWidgets('Why speaks the sweep and the books', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(
        find.textContaining('exactly one crossing'),
        findsOne,
      );
      expect(find.textContaining('65,536'), findsOne);
      expect(
        find.textContaining('short diagonal'),
        findsWidgets,
      );
    });

    testWidgets('the linking lands the card', (tester) async {
      await open(tester, which: 0);
      await linkIt(tester);
      expect(find.text('west meets east'), findsOne);
      expect(
        find.textContaining('this one is yours'),
        findsOne,
      );
    });

    testWidgets('every winnable field links by the solve',
        (tester) async {
      for (var number = 0; number < Fields.count; number++) {
        final field = Fields.at(number);
        if (!field.winnable) continue;
        await open(tester, which: number);
        await linkIt(tester);
        expect(state(tester).play.isDone, isTrue,
            reason: field.name);
      }
    });

    testWidgets('the linking writes the steps down', (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await linkIt(tester);
      await tester.pump();
      expect(best.stepsFor('The Three Field'),
          state(tester).play.moves);
      expect(await best.record('The Three Field', 99), isFalse);
    });
  });

  group('the pies', () {
    testWidgets('the pie is judged before any step', (tester) async {
      await open(tester, which: 2);
      expect(state(tester).play.pieOpen, isTrue);
      await tapTussock(tester, 5);
      expect(state(tester).play.moves, 0);
      expect(
        find.textContaining('The pie is on the table'),
        findsOne,
      );
      expect(find.text('Take the pie'), findsOne);
    });

    testWidgets('show me judges the strong opening taken',
        (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Show me');
      expect(state(tester).pieLit, 'take');
      expect(
        find.textContaining('survives perfect play'),
        findsOne,
      );
    });

    testWidgets('show me waves the weak opening by', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Show me');
      expect(state(tester).pieLit, 'decline');
      expect(
        find.textContaining('off the short diagonal'),
        findsOne,
      );
    });

    testWidgets('declining the strong pie is called out',
        (tester) async {
      await open(tester, which: 2);
      await press(tester, 'Wave it by');
      expect(
        find.textContaining('the solve now holds the far chair'),
        findsOne,
      );
      await press(tester, 'Back');
      expect(state(tester).play.pieOpen, isTrue);
    });
  });

  group('the second chair', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('every line from this chair loses'),
        findsOne,
      );
    });

    testWidgets('show me has nothing to point at', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('the mere crosses and the card admits it',
        (tester) async {
      await open(tester, which: 4);
      var guard = 0;
      while (!state(tester).play.isOver) {
        if (guard++ > 16) fail('the chair never fell');
        await tapTussock(
            tester, state(tester).play.cells.indexOf(0));
      }
      expect(state(tester).play.isLost, isTrue);
      expect(
        find.textContaining('as the label said they must'),
        findsOne,
      );
      expect(
        find.text('the mere crossed, as the label said'),
        findsOne,
      );
    });
  });
}
