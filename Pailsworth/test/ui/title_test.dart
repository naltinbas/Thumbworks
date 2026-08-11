import 'package:flutter_test/flutter_test.dart';
import 'package:pailsworth/pail/errands.dart';

import '../support/pail.dart';

void main() {
  group('the shelf of errands', () {
    testWidgets('names the game and every errand', (tester) async {
      await open(tester);
      expect(find.text('Pailsworth'), findsOne);
      for (var number = 0; number < Errands.count; number++) {
        expect(find.text(Errands.at(number).name), findsOne);
      }
    });

    testWidgets('the third pint is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no pouring ever will'), findsOne);
    });

    testWidgets('a row opens its errand', (tester) async {
      await open(tester);
      await tester.tap(find.text(Errands.at(3).name));
      await tester.pump();
      expect(state(tester).play.errand.name, Errands.at(3).name);
    });

    testWidgets('leaving an errand lands back on the shelf',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the errands'));
      await tester.pump();
      expect(find.text('Pailsworth'), findsOne);
    });
  });
}
