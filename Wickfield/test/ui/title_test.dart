import 'package:flutter_test/flutter_test.dart';
import 'package:wickfield/wick/wicks.dart';

import '../support/wick.dart';

void main() {
  group('the field of wicks', () {
    testWidgets('names the game and every wick', (tester) async {
      await open(tester);
      expect(find.text('Wickfield'), findsOne);
      for (var number = 0; number < Wicks.count; number++) {
        expect(find.text(Wicks.at(number).name), findsOne);
      }
    });

    testWidgets('the dead lamp is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('never goes dark'), findsOne);
    });

    testWidgets('a row opens its wick', (tester) async {
      await open(tester);
      await tester.tap(find.text(Wicks.at(2).name));
      await tester.pump();
      expect(state(tester).play.wick.name, Wicks.at(2).name);
    });

    testWidgets('leaving a wick lands back on the field', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the wicks'));
      await tester.pump();
      expect(find.text('Wickfield'), findsOne);
    });
  });
}
