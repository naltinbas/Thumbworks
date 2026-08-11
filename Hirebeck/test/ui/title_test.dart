import 'package:flutter_test/flutter_test.dart';
import 'package:hirebeck/book/days.dart';

import '../support/book.dart';

void main() {
  group('the ledger of days', () {
    testWidgets('names the game and every day', (tester) async {
      await open(tester);
      expect(find.text('Hirebeck'), findsOne);
      for (var number = 0; number < Days.count; number++) {
        expect(find.text(Days.at(number).name), findsOne);
      }
    });

    testWidgets('the extra guest is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('cannot hold them'), findsOne);
    });

    testWidgets('a row opens its day', (tester) async {
      await open(tester);
      await tester.tap(find.text(Days.at(2).name));
      await tester.pump();
      expect(state(tester).play.day.name, Days.at(2).name);
    });

    testWidgets('leaving a day lands back on the ledger',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the days'));
      await tester.pump();
      expect(find.text('Hirebeck'), findsOne);
    });
  });
}
