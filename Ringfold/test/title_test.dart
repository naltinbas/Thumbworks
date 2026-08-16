import 'package:flutter_test/flutter_test.dart';
import 'package:ringfold/period/levels.dart';

import 'support/fonts.dart';
import 'support/periodland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Ringfold'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Eight'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Wind the clock up or down, by one or by ten hours a tap'),
      findsOneWidget,
    );
  });

  testWidgets('a clock come round writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Eight'));
    await tester.pumpAndSettle();
    await wind(tester, 1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
