import 'package:flutter_test/flutter_test.dart';
import 'package:pennygill/toss/call.dart';

import '../support/toss.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the calls on offer', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.yours, isNull);
      expect(find.text('0 : 0'), findsOne);
      expect(find.text('first to 1'), findsOne);
    });

    testWidgets('your call brings the house reply and says so',
        (tester) async {
      await open(tester, which: 0);
      await call(tester, const Call(6));
      expect(state(tester).play.yours!.said, 'HHT');
      expect(state(tester).play.theirs!.said, 'THH');
      expect(find.textContaining('the house calls THH'), findsOne);
    });

    testWidgets('the held table refuses any other call', (tester) async {
      await open(tester, which: 2);
      await call(tester, const Call(6));
      expect(state(tester).play.yours, isNull);
      expect(find.textContaining('holds you to HHH'), findsOne);
      await call(tester, const Call(7));
      expect(state(tester).play.yours!.said, 'HHH');
    });

    testWidgets('Toss flips coins until somebody\'s call shows',
        (tester) async {
      await open(tester, which: 0);
      await call(tester, const Call(6));
      await tossItOut(tester);
      expect(state(tester).play.isOver, isTrue);
    });

    testWidgets('Again deals the table fresh', (tester) async {
      await open(tester, which: 0);
      await call(tester, const Call(6));
      await press(tester, 'Again');
      expect(state(tester).play.yours, isNull);
    });
  });

  group('the words under the table', () {
    testWidgets('Show me before calling tells the truth of the table',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).hints, 1);
      expect(find.textContaining('There is no good call'), findsOne);
    });

    testWidgets('and on the turned table points at the beating reply',
        (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Show me');
      expect(state(tester).pointing!.said, 'HHT');
      expect(find.textContaining('ends where yours begins'), findsOne);
    });

    testWidgets('Why draws the ring and owns the odds', (tester) async {
      await open(tester, which: 0);
      await call(tester, const Call(6));
      await press(tester, 'Why');
      expect(state(tester).showRing, isTrue);
      expect(find.textContaining('no best call'), findsOne);
      expect(find.textContaining('3 in 4'), findsOne);
    });

    testWidgets('the even table says why it is fair', (tester) async {
      await open(tester, which: 4);
      await call(tester, const Call(6));
      await press(tester, 'Why');
      expect(find.textContaining('trade places'), findsOne);
    });
  });

  group('a match settled', () {
    testWidgets('the card owns the odds either way', (tester) async {
      await open(tester, which: 0);
      await call(tester, const Call(6));
      await tossItOut(tester);
      final won = state(tester).play.won;
      if (won) {
        expect(find.textContaining('luck'), findsOne);
      } else {
        expect(find.textContaining('whole trick'), findsOne);
      }
    });

    testWidgets('Next opens the table after', (tester) async {
      await open(tester, which: 0);
      await call(tester, const Call(6));
      await tossItOut(tester);
      await press(tester, 'Next');
      expect(state(tester).play.wager.name, 'The Long Run');
    });
  });
}
