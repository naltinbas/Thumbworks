import 'package:flutter_test/flutter_test.dart';
import 'package:spindlewood/tower/spindles.dart';

import '../support/tower.dart';

void main() {
  group('the bench of towers', () {
    testWidgets('names the game and every tower', (tester) async {
      await open(tester);
      expect(find.text('Spindlewood'), findsOne);
      for (var number = 0; number < Spindles.count; number++) {
        expect(find.text(Spindles.at(number).name), findsOne);
      }
    });

    testWidgets('the wager is labelled lost on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('the walk calls lost'), findsOne);
    });

    testWidgets('a row opens its tower', (tester) async {
      await open(tester);
      await tester.tap(find.text(Spindles.at(3).name));
      await tester.pump();
      expect(state(tester).play.spindle.name, Spindles.at(3).name);
    });

    testWidgets('leaving a tower lands back on the bench', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the towers'));
      await tester.pump();
      expect(find.text('Spindlewood'), findsOne);
    });
  });
}
