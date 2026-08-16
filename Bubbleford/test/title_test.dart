import 'package:flutter_test/flutter_test.dart';
import 'package:bubbleford/kiss/levels.dart';

import 'support/fonts.dart';
import 'support/bubbleland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Bubbleford'), findsOneWidget);
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
    await tester.tap(find.text('The Unit Ring'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Step the three bends, one to twenty'),
      findsOneWidget,
    );
  });

  testWidgets('a setting writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Unit Ring'));
    await tester.pumpAndSettle();
    await setBends(tester, [2, 2, 3]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
