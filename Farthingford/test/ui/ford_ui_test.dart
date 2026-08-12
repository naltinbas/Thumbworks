import 'package:flutter_test/flutter_test.dart';
import 'package:farthingford/best.dart';
import 'package:farthingford/ford/reaches.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/ford.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('a reach opened', () {
    testWidgets('runs the stream and names the ford', (tester) async {
      await open(tester, which: 1);
      expect(find.text('The Three Fifths'), findsOne);
      expect(find.text('0 wades'), findsOne);
      expect(find.text('wade to 3/5'), findsOne);
      expect(find.textContaining('The gold stone is the banks'),
          findsOne);
    });

    testWidgets('a wade takes the stone for a bank', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Wade right');
      expect(state(tester).play.bankA, (1, 2));
      expect(state(tester).play.wades, 1);
      expect(find.text('1 wade'), findsOne);
    });

    testWidgets('a wrong wade is called out by name', (tester) async {
      await open(tester, which: 1);
      // 3/5 sits right of the half, so left loses it.
      await press(tester, 'Wade left');
      expect(state(tester).play.holdsTarget, isFalse);
      expect(
        find.textContaining('left 3/5 behind'),
        findsOne,
      );
    });

    testWidgets('a wrong crossing is refused with the stone named',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Cross here');
      expect(state(tester).play.isDone, isFalse);
      expect(
        find.textContaining('The stone is 1/2, not the ford'),
        findsOne,
      );
    });

    testWidgets('Back wades out', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Wade left');
      await press(tester, 'Back');
      expect(state(tester).play.wades, 0);
      expect(state(tester).play.holdsTarget, isTrue);
    });

    testWidgets('Again starts the reach over', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Wade right');
      await press(tester, 'Again');
      expect(state(tester).play.wades, 0);
      expect(state(tester).play.bankA, (0, 1));
    });

    testWidgets('Show me lights the walk\'s own way', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, 'right');
      expect(
        find.textContaining('the ford lies between the stone and '
            'the right bank'),
        findsOne,
      );
    });

    testWidgets('Why speaks the kissing and the counts',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Why');
      expect(
        find.textContaining('circles kiss'),
        findsOne,
      );
      expect(find.textContaining('all 253 pairs'), findsOne);
    });

    testWidgets('the crossing lands the card', (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Cross here');
      expect(find.text('the crossing is made'), findsOne);
      expect(
        find.textContaining('the walk\'s own count'),
        findsOne,
      );
    });

    testWidgets('every winnable reach lands in its written wades by '
        'the walk', (tester) async {
      for (var number = 0; number < Reaches.count; number++) {
        final reach = Reaches.at(number);
        if (!reach.winnable) continue;
        await open(tester, which: number);
        await wadeIt(tester);
        expect(state(tester).play.wades, reach.wades,
            reason: reach.name);
      }
    });

    testWidgets('the crossing writes the wades down', (tester) async {
      final best = await keeper();
      await open(tester, which: 0, best: best);
      await wadeIt(tester);
      await tester.pump();
      expect(best.wadesFor('The First Ford'), 1);
      expect(await best.record('The First Ford', 9), isFalse);
    });
  });

  group('the shallow ford', () {
    testWidgets('is labelled hopeless on the way in', (tester) async {
      await open(tester, which: 4);
      expect(
        find.textContaining('nothing shallower than fifths'),
        findsOne,
      );
      expect(
        find.text('cross shallower than fifths: no ford of any '
            'depth does'),
        findsOne,
      );
    });

    testWidgets('show me has nothing to point at', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNull);
      expect(find.textContaining('There is nothing to show'), findsOne);
    });

    testWidgets('why speaks the depth lemma', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Why');
      expect(
        find.textContaining('depths put together'),
        findsOne,
      );
      expect(find.textContaining('all 43 kissing pairs'), findsOne);
    });

    testWidgets('eight wades only deepen, and the reach admits it',
        (tester) async {
      await open(tester, which: 4);
      for (var wade = 0; wade < 8; wade++) {
        expect(state(tester).play.stone.$2, greaterThanOrEqualTo(5));
        await press(
            tester, wade.isEven ? 'Wade left' : 'Wade right');
      }
      expect(state(tester).play.gaveUp, isTrue);
      expect(
        find.textContaining('every stone ran fifths or deeper'),
        findsOne,
      );
      expect(
        find.text('never shallower, as the label said'),
        findsOne,
      );
    });
  });
}
