import 'package:flutter_test/flutter_test.dart';
import 'package:tallowfield/garden/evenings.dart';

import '../support/garden.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the complaints standing', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.settled, isFalse);
      expect(find.text('1 hedge complains'), findsOne);
      expect(find.text('no slips'), findsOne);
    });

    testWidgets('naming the right lantern settles the evening',
        (tester) async {
      await open(tester, which: 0);
      await name(tester, 1);
      expect(state(tester).play.settled, isTrue);
      expect(find.textContaining('Lamp 1 it was'), findsOne);
    });

    testWidgets('naming wrong is counted and corrected', (tester) async {
      await open(tester, which: 0);
      await name(tester, 4);
      expect(state(tester).play.settled, isFalse);
      expect(state(tester).play.slips, 1);
      expect(find.text('1 slip'), findsOne);
      expect(find.textContaining('Not lamp 4'), findsOne);
    });

    testWidgets('Again starts the evening over', (tester) async {
      await open(tester, which: 0);
      await name(tester, 4);
      await press(tester, 'Again');
      expect(state(tester).play.slips, 0);
    });
  });

  group('the words under the garden', () {
    testWidgets('the quiet garden settles on all\'s well', (tester) async {
      await open(tester, which: 2);
      await press(tester, "All's well");
      expect(state(tester).play.settled, isTrue);
      expect(find.textContaining('All was well'), findsOne);
    });

    testWidgets('and complains when all\'s well is claimed too soon',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, "All's well");
      expect(state(tester).play.slips, 1);
      expect(find.textContaining('not as the gardener left it'), findsOne);
    });

    testWidgets('Show me points where the tallies point', (tester) async {
      await open(tester, which: 1);
      await press(tester, 'Show me');
      expect(state(tester).pointing, 7);
      expect(state(tester).hints, 1);
      expect(find.textContaining('point at lamp 7'), findsOne);
    });

    testWidgets('Why speaks the rule and tonight\'s reading', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Why');
      expect(state(tester).showBeds, isTrue);
      expect(find.textContaining('even count'), findsOne);
      expect(find.textContaining('which is lamp 6'), findsOne);
    });
  });

  group('an evening settled', () {
    testWidgets('the honest evenings say the tallies told the truth',
        (tester) async {
      for (final number in const [0, 1, 3]) {
        await open(tester, which: number);
        await name(tester, Evenings.at(number).snuffed.single);
        expect(state(tester).play.settled, isTrue,
            reason: Evenings.at(number).name);
        expect(find.textContaining('told the truth'), findsOne);
      }
    });

    testWidgets('the double draught settles on the tallies\' word and owns '
        'the mistake', (tester) async {
      await open(tester, which: 4);
      await name(tester, 7);
      expect(state(tester).play.settled, isTrue);
      expect(find.textContaining('and they were wrong'), findsOne);
      expect(find.textContaining('lamps 2 and 5'), findsOne);
    });

    testWidgets('Next opens the evening after', (tester) async {
      await open(tester, which: 0);
      await name(tester, 1);
      await press(tester, 'Next');
      expect(state(tester).play.evening.name, Evenings.at(1).name);
    });
  });
}
