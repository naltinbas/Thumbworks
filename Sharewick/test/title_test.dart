import 'package:flutter_test/flutter_test.dart';
import 'package:sharewick/trio/levels.dart';

import 'support/fonts.dart';
import 'support/trioland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Sharewick'), findsOneWidget);
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
    await tester.tap(find.text('The Ten'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a trio to pick it, and again to unpick it'),
      findsOneWidget,
    );
  });

  testWidgets('a family writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Star'));
    await tester.pumpAndSettle();
    await pickAll(tester, ['ABC', 'ABD', 'ABE', 'ABF', 'ACD', 'ACE', 'ACF', 'ADE', 'ADF', 'AEF']);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 10'), findsOneWidget);
  });
}
