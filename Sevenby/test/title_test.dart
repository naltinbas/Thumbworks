import 'package:flutter_test/flutter_test.dart';
import 'package:sevenby/turn/levels.dart';

import 'support/fonts.dart';
import 'support/turnland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Sevenby'), findsOneWidget);
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
    await tester.tap(find.text('The Six'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Turn the dials, a step a tap, and watch the decimal come round'),
      findsOneWidget,
    );
  });

  testWidgets('a fraction come round writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Six'));
    await tester.pumpAndSettle();
    await setDials(tester, 7, 1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
