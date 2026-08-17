import 'package:flutter_test/flutter_test.dart';
import 'package:truckleford/yard/levels.dart';
import 'package:truckleford/yard/rules.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Truckleford'), findsOneWidget);
    expect(
      find.textContaining(
          'so long as it is an order a single siding can make'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Reversal'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Shunt a wagon onto the siding, roll one straight '
          'out, or send out the one at the points'),
      findsOneWidget,
    );
  });

  testWidgets('a run writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('Nothing Moved'));
    await tester.pumpAndSettle();
    await run(tester, List.filled(Rules.wagons, Rules.roll));
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 6'), findsOneWidget);
  });
}
