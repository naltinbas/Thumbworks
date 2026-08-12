import 'package:flutter_test/flutter_test.dart';
import 'package:knuckleby/best.dart';
import 'package:knuckleby/bones/benches.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/bones.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a bench opened', () {
    testWidgets('sets the blanks out and names the trade',
        (tester) async {
      await open(tester, which: 0);
      expect(find.text('The Little Pair'), findsOne);
      expect(find.text('0 cuts'), findsOne);
      expect(
        find.textContaining('find a pair beside the standard'),
        findsOne,
      );
      expect(find.textContaining('Tap a face to cut'), findsOne);
    });

    testWidgets('a tapped face cuts one pip higher', (tester) async {
      await open(tester, which: 0);
      await tapFace(tester, 0, 2);
      expect(state(tester).play.one, [1, 1, 2, 1]);
      expect(find.text('1 cut'), findsOne);
    });

    testWidgets('the locked die refuses the knife', (tester) async {
      await open(tester, which: 2);
      await tapFace(tester, 0, 0);
      expect(state(tester).play.cuts, 0);
      expect(
        find.textContaining('locked as the bench asks'),
        findsOne,
      );
    });

    testWidgets('a wandered cut is called out', (tester) async {
      await open(tester, which: 0);
      // Bring the bench within one cut of the other pair, then
      // find, not guess, a cut that moves it further off.
      const other = ([1, 2, 2, 3], [1, 3, 3, 5]);
      for (var face = 0; face < 4; face++) {
        await cutTo(tester, 0, face, other.$1[face]);
        if (face < 3) {
          await cutTo(tester, 1, face, other.$2[face]);
        }
      }
      final play = state(tester).play;
      final could = play.apart;
      expect(could, greaterThan(0));
      (int, int)? wander;
      for (var die = 0; die < 2 && wander == null; die++) {
        for (var face = 0; face < 4 && wander == null; face++) {
          if (play.cut(die, face).apart > could) {
            wander = (die, face);
          }
        }
      }
      expect(wander, isNotNull,
          reason: 'every cut moves this bench nearer');
      await tapFace(tester, wander!.$1, wander.$2);
      expect(
        find.textContaining('moved the bones no nearer'),
        findsOne,
      );
    });

    testWidgets('matching the standard is refused where the other '
        'is asked', (tester) async {
      await open(tester, which: 0);
      for (var face = 0; face < 4; face++) {
        await cutTo(tester, 0, face, face + 1);
        await cutTo(tester, 1, face, face + 1);
      }
      expect(state(tester).play.matches, isTrue);
      expect(state(tester).play.isDone, isFalse);
      expect(
        find.textContaining('the bench asks for the OTHER pair'),
        findsOne,
      );
    });

    testWidgets('Back uncuts', (tester) async {
      await open(tester, which: 0);
      await tapFace(tester, 0, 1);
      await press(tester, 'Back');
      expect(state(tester).play.one, [1, 1, 1, 1]);
      expect(state(tester).play.cuts, 0);
    });

    testWidgets('Again starts the bench over', (tester) async {
      await open(tester, which: 0);
      await tapFace(tester, 0, 1);
      await press(tester, 'Again');
      expect(state(tester).play.cuts, 0);
      expect(state(tester).play.one, [1, 1, 1, 1]);
    });

    testWidgets('Show me points a face and its pip', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      final cut = state(tester).play.pointed;
      expect(state(tester).pointing, (cut!.$1, cut.$2));
      expect(
        find.textContaining('the nearest matching pair holds'),
        findsOne,
      );
    });

    testWidgets('Why speaks the trade and the factors',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(
        find.textContaining('tables agree to the last count'),
        findsOne,
      );
      expect(find.textContaining('factor-trade'), findsOne);
    });

    testWidgets('every winnable bench trades by the pointer',
        (tester) async {
      for (var number = 0; number < Benches.count; number++) {
        final bench = Benches.at(number);
        if (!bench.winnable) continue;
        await open(tester, which: number);
        await tradeIt(tester);
        expect(state(tester).play.isDone, isTrue,
            reason: bench.name);
      }
    });

    testWidgets('the trade writes the cuts down', (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await tradeIt(tester);
      await tester.pump();
      expect(best.cutsFor('The Little Pair'),
          state(tester).play.cuts);
      expect(await best.record('The Little Pair', 99), isFalse);
    });
  });

  group('the even bones', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('no even-pipped pair ever matches'),
        findsOne,
      );
    });

    testWidgets('cuts run by twos', (tester) async {
      await open(tester, which: 4);
      await tapFace(tester, 0, 0);
      expect(state(tester).play.one[0], 4);
    });

    testWidgets('show me has nothing to point at', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('why speaks the parity', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(find.textContaining('three is odd'), findsOne);
      expect(find.textContaining('3,570'), findsOne);
    });

    testWidgets('eight cuts and the bench admits it', (tester) async {
      await open(tester, which: 4);
      for (var turn = 0; turn < 8; turn++) {
        await tapFace(tester, 1, turn % 6);
      }
      expect(state(tester).play.gaveUp, isTrue);
      expect(
        find.textContaining('the table never matched'),
        findsOne,
      );
      expect(
        find.text('unmatched, as the label said it must stay'),
        findsOne,
      );
    });
  });
}
