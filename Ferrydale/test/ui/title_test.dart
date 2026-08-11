import 'package:ferrydale/ferry/ferries.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/ferry.dart';

void main() {
  group('the dale of ferries', () {
    testWidgets('names the game and every ferry', (tester) async {
      await open(tester);
      expect(find.text('Ferrydale'), findsOne);
      for (var number = 0; number < Ferries.count; number++) {
        expect(find.text(Ferries.at(number).name), findsOne);
      }
    });

    testWidgets('the four and four are labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('never fills'), findsOne);
    });

    testWidgets('a row opens its ferry', (tester) async {
      await open(tester);
      await tester.tap(find.text(Ferries.at(2).name));
      await tester.pump();
      expect(state(tester).play.ferry.name, Ferries.at(2).name);
    });

    testWidgets('leaving a ferry lands back on the dale',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the ferries'));
      await tester.pump();
      expect(find.text('Ferrydale'), findsOne);
    });
  });
}
