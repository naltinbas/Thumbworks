import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wardhall/best.dart';
import 'package:wardhall/hall/halls.dart';

import '../support/hall.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a hall opened', () {
    testWidgets('lays the floor dark and names the asking',
        (tester) async {
      await open(tester, which: 0);
      expect(find.text('The Ell'), findsOne);
      expect(find.text('0 of 1'), findsOne);
      expect(
        find.textContaining('light every flag with 1 ward'),
        findsOne,
      );
      expect(find.textContaining('Tap a corner to post'), findsOne);
      expect(state(tester).play.unlit, isNotEmpty);
    });

    testWidgets('a posted ward lights what it sees', (tester) async {
      await open(tester, which: 1);
      final dark = state(tester).play.unlit.length;
      await tapCorner(tester, 0);
      expect(state(tester).play.wards, [0]);
      expect(state(tester).play.unlit.length, lessThan(dark));
    });

    testWidgets('a lantern lifts when tapped again', (tester) async {
      await open(tester, which: 1);
      await tapCorner(tester, 0);
      await tapCorner(tester, 0);
      expect(state(tester).play.wards, isEmpty);
    });

    testWidgets('a short full watch is told to lift', (tester) async {
      await open(tester, which: 1);
      // Found, not guessed: a pair that leaves dark flags.
      final play = state(tester).play;
      (int, int)? dim;
      for (var one = 0; one < 8 && dim == null; one++) {
        for (var two = one + 1; two < 8 && dim == null; two++) {
          if (play.post(one).post(two).unlit.isNotEmpty) {
            dim = (one, two);
          }
        }
      }
      expect(dim, isNotNull);
      await tapCorner(tester, dim!.$1);
      await tapCorner(tester, dim.$2);
      expect(
        find.textContaining('lift a lantern and try another'),
        findsOne,
      );
      // A third post is refused while the watch is full.
      await tapCorner(tester, 7);
      expect(state(tester).play.wards, hasLength(2));
      expect(
        find.textContaining('The watch is at its full'),
        findsOne,
      );
    });

    testWidgets('Back stands the last change down', (tester) async {
      await open(tester, which: 1);
      await tapCorner(tester, 0);
      await press(tester, 'Back');
      expect(state(tester).play.wards, isEmpty);
    });

    testWidgets('Show me points a working watch\'s corner',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNotNull);
      expect(
        find.textContaining('a full watch within the asking'),
        findsOne,
      );
    });

    testWidgets('Why speaks the colouring and the sweep',
        (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(
        find.textContaining('no triangle repeats one'),
        findsOne,
      );
      expect(
        find.textContaining('the colouring is a roof over it'),
        findsOne,
      );
    });

    testWidgets('the lit hall lands the card', (tester) async {
      await open(tester, which: 0);
      await lightIt(tester);
      expect(find.text('every flag is lit'), findsOne);
      expect(
        find.textContaining('the fewest this hall allows'),
        findsOne,
      );
    });

    testWidgets('every winnable hall lights by the pointer',
        (tester) async {
      for (var number = 0; number < Halls.count; number++) {
        final hall = Halls.at(number);
        if (!hall.winnable) continue;
        await open(tester, which: number);
        await lightIt(tester);
        expect(state(tester).play.isDone, isTrue, reason: hall.name);
      }
    });

    testWidgets('the lighting writes the askings down',
        (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await lightIt(tester);
      await tester.pump();
      expect(best.askingsFor('The Ell'), 0);
      expect(await best.record('The Ell', 9), isFalse);
    });
  });

  group('the comb short', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('this comb needs three'),
        findsOne,
      );
    });

    testWidgets('show me has nothing to point at', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('all sixty-six pairs'), findsOne);
    });

    testWidgets('why holds the colouring against the sweep',
        (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(find.textContaining('the fewest is 3'), findsOne);
      expect(
        find.textContaining('even it cannot get under the sweep'),
        findsOne,
      );
    });

    testWidgets('two wards leave a tooth dark and the card admits '
        'it', (tester) async {
      await open(tester, which: 4);
      await tapCorner(tester, 0);
      await tapCorner(tester, 1);
      expect(state(tester).play.isOver, isTrue);
      expect(
        find.textContaining('This comb needs three'),
        findsOne,
      );
      expect(
        find.text('a tooth stays dark, as the label said'),
        findsOne,
      );
    });
  });
}
