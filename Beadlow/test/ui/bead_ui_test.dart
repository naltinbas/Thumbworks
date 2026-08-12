import 'package:flutter_test/flutter_test.dart';
import 'package:beadlow/best.dart';
import 'package:beadlow/bead/rings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/bead.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a ring opened', () {
    testWidgets('lays the beads out and names the asking',
        (tester) async {
      await open(tester, which: 0);
      expect(find.text('The Three'), findsOne);
      expect(find.text('0 of 4'), findsOne);
      expect(find.text('string 4 necklaces, no two alike'), findsOne);
      expect(find.textContaining('Tap a bead to dye it'), findsOne);
    });

    testWidgets('a tapped bead dyes onward', (tester) async {
      await open(tester, which: 0);
      await tapBead(tester, 1);
      expect(state(tester).play.beads, [0, 1, 0]);
    });

    testWidgets('a new string lands on the shelf', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'String it');
      expect(state(tester).play.strung, hasLength(1));
      expect(find.text('1 of 4'), findsOne);
      expect(find.textContaining('Strung: 1 of the 4'), findsOne);
    });

    testWidgets('a turned repeat is named on the shelf',
        (tester) async {
      await open(tester, which: 0);
      await dyeTo(tester, 0, 1);
      await press(tester, 'String it');
      // (0,1,0) is (1,0,0) turned: the same necklace.
      await dyeTo(tester, 0, 0);
      await dyeTo(tester, 1, 1);
      expect(state(tester).play.alreadyAt, 0);
      await press(tester, 'String it');
      expect(state(tester).play.strung, hasLength(1));
      expect(state(tester).named, 0);
      expect(
        find.textContaining('necklace 1 on the shelf, only turned'),
        findsOne,
      );
    });

    testWidgets('Back undyes and unstrings', (tester) async {
      await open(tester, which: 0);
      await tapBead(tester, 1);
      await press(tester, 'Back');
      expect(state(tester).play.beads, [0, 0, 0]);
      await press(tester, 'String it');
      expect(state(tester).play.strung, hasLength(1));
      await press(tester, 'Back');
      expect(state(tester).play.strung, isEmpty);
    });

    testWidgets('Show me ghosts a missing necklace', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'String it');
      await press(tester, 'Show me');
      expect(state(tester).ghost, isNotNull);
      expect(state(tester).play.missing, state(tester).ghost);
      expect(
        find.textContaining('Dye the beads to the small marks'),
        findsOne,
      );
    });

    testWidgets('Why counts what the turns fix', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(
        find.textContaining('64, 2, 4, 8, 4, 2'),
        findsOne,
      );
      expect(find.textContaining('84 over the 6 turns is 14'), findsOne);
    });

    testWidgets('the filled shelf lands the card', (tester) async {
      await open(tester, which: 0);
      await shelveIt(tester);
      expect(find.text('the shelf is full'), findsOne);
      expect(
        find.textContaining('none of them a repeat'),
        findsOne,
      );
    });

    testWidgets('every winnable ring fills by the pointer',
        (tester) async {
      for (var number = 0; number < Rings.count; number++) {
        final ring = Rings.at(number);
        if (!ring.winnable) continue;
        await open(tester, which: number);
        await shelveIt(tester);
        expect(state(tester).play.strung, hasLength(ring.asked),
            reason: ring.name);
      }
    });

    testWidgets('the filling writes the strings down',
        (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await shelveIt(tester);
      await tester.pump();
      expect(best.stringsFor('The Three'), 4);
      expect(await best.record('The Three', 99), isFalse);
    });
  });

  group('the seventh', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('this ring holds six'),
        findsOne,
      );
    });

    testWidgets('show me after the shelf fills has nothing',
        (tester) async {
      await open(tester, which: 4);
      var guard = 0;
      while (state(tester).play.strung.length < 6) {
        if (guard++ > 10) fail('the shelf never filled');
        final missing = state(tester).play.missing!;
        for (var at = 0; at < 4; at++) {
          await dyeTo(tester, at, missing[at]);
        }
        await press(tester, 'String it');
      }
      await press(tester, 'Show me');
      expect(state(tester).ghost, isNull);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('why says the asking outruns the ring',
        (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(find.textContaining('16, 2, 4, 2'), findsOne);
      expect(
        find.textContaining('the ring holds only 6'),
        findsOne,
      );
    });

    testWidgets('the string past the full shelf jams it',
        (tester) async {
      await open(tester, which: 4);
      var guard = 0;
      while (state(tester).play.strung.length < 6) {
        if (guard++ > 10) fail('the shelf never filled');
        final missing = state(tester).play.missing!;
        for (var at = 0; at < 4; at++) {
          await dyeTo(tester, at, missing[at]);
        }
        await press(tester, 'String it');
      }
      await press(tester, 'String it');
      expect(state(tester).play.gaveUp, isTrue);
      expect(
        find.textContaining('the seventh was never there'),
        findsOne,
      );
      expect(
        find.text('six of seven, and six is the whole ring'),
        findsOne,
      );
    });
  });
}
