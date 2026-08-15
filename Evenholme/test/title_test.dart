import 'package:flutter_test/flutter_test.dart';
import 'package:evenholme/split/levels.dart';

import 'support/fonts.dart';
import 'support/splitland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Evenholme'), findsOneWidget);
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
    await tester.tap(find.text('The Twenty'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a number and its partner lights'),
      findsOneWidget,
    );
  });

  testWidgets('a split writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Twenty'));
    await tester.pumpAndSettle();
    await tapNumber(tester, 7);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
