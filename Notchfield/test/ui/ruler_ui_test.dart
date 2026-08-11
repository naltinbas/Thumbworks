import 'package:flutter_test/flutter_test.dart';
import 'package:notchfield/ruler/cuts.dart';

import '../support/ruler.dart';

void main() {
  group('the screen', () {
    testWidgets('opens uncut', (tester) async {
      await open(tester, which: 1);
      expect(state(tester).play.notched, isEmpty);
      expect(find.text('0 of 4 notches cut'), findsOne);
      expect(find.text('0 moved'), findsOne);
    });

    testWidgets('a tap cuts a notch, another fills it', (tester) async {
      await open(tester, which: 1);
      await tapMark(tester, 4);
      expect(state(tester).play.notched, [4]);
      await tapMark(tester, 4);
      expect(state(tester).play.notched, isEmpty);
      expect(find.text('2 moved'), findsOne);
    });

    testWidgets('a full rule refuses another notch with the words',
        (tester) async {
      await open(tester, which: 0);
      await tapMark(tester, 0);
      await tapMark(tester, 1);
      await tapMark(tester, 2);
      await tapMark(tester, 3);
      expect(state(tester).play.notched, hasLength(3));
      expect(find.textContaining('fill one before cutting'), findsOne);
    });

    testWidgets('Back unmoves the last move', (tester) async {
      await open(tester, which: 1);
      await tapMark(tester, 4);
      await press(tester, 'Back');
      expect(state(tester).play.notched, isEmpty);
    });

    testWidgets('Again clears the rule', (tester) async {
      await open(tester, which: 1);
      await tapMark(tester, 0);
      await tapMark(tester, 4);
      await press(tester, 'Again');
      expect(state(tester).play.moves, 0);
    });
  });

  group('the words under the rule', () {
    testWidgets('a doubled length is called out with its pairs',
        (tester) async {
      await open(tester, which: 1);
      await tapMark(tester, 0);
      await tapMark(tester, 1);
      await tapMark(tester, 2);
      expect(find.textContaining('measured twice now: 0 to 1'),
          findsOne);
      expect(find.textContaining('1 length measured twice'), findsOne);
    });

    testWidgets('Show me mends toward a counted cutting',
        (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, isNot(-1));
      expect(state(tester).hints, 1);
      expect(find.textContaining('the sweep counted'), findsOne);
    });

    testWidgets('Why speaks the census and the count', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(find.textContaining('green once'), findsOne);
      expect(find.textContaining('4 cuttings'), findsOne);
    });

    testWidgets('the perfect ten says so as it opens, and Why counts '
        'the slack', (tester) async {
      await open(tester, which: 4);
      expect(find.textContaining('No cutting of this ruler'), findsOne);
      await press(tester, 'Show me');
      expect(state(tester).pointing, -1);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('every way a 10-length allows'),
          findsOne);
      expect(find.textContaining('no slack'), findsOne);
    });
  });

  group('a ruler cut true', () {
    testWidgets('following the game cuts every winnable ruler',
        (tester) async {
      for (var number = 0; number < Cuts.count; number++) {
        final cut = Cuts.at(number);
        if (!cut.winnable) continue;
        await open(tester, which: number);
        await cutItTrue(tester);
        expect(state(tester).play.isDone, isTrue, reason: cut.name);
      }
    });

    testWidgets('the card owns the ways and the ask', (tester) async {
      await open(tester, which: 1);
      await cutItTrue(tester);
      expect(find.text('every length measured once'), findsOne);
      expect(find.textContaining('one of 2 cuttings'), findsOne);
    });

    testWidgets('Next opens the ruler after', (tester) async {
      await open(tester, which: 0);
      await cutItTrue(tester);
      await press(tester, 'Next');
      expect(state(tester).play.cut.name, Cuts.at(1).name);
    });
  });
}
