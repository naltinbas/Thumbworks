import 'package:flutter_test/flutter_test.dart';
import 'package:shuntley/shunt/trays.dart';

import '../support/shunt.dart';

void main() {
  group('the bench of trays', () {
    testWidgets('names the game and every tray', (tester) async {
      await open(tester);
      expect(find.text('Shuntley'), findsOne);
      for (var number = 0; number < Trays.count; number++) {
        expect(find.text(Trays.at(number).name), findsOne);
      }
    });

    testWidgets('the swindle is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('never comes home'), findsOne);
    });

    testWidgets('a row opens its tray', (tester) async {
      await open(tester);
      await tester.tap(find.text(Trays.at(2).name));
      await tester.pump();
      expect(state(tester).play.tray.name, Trays.at(2).name);
    });

    testWidgets('leaving a tray lands back on the bench', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the trays'));
      await tester.pump();
      expect(find.text('Shuntley'), findsOne);
    });
  });
}
