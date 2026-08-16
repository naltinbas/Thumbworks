import 'package:flutter_test/flutter_test.dart';
import 'package:trebleworth/heap/levels.dart';

import 'support/fonts.dart';
import 'support/heapland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Trebleworth'), findsOneWidget);
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
      find.textContaining('Tap a heap on the shelf to set it in the next slot'),
      findsOneWidget,
    );
  });

  testWidgets('a heaping writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Twenty'));
    await tester.pumpAndSettle();
    await takeAll(tester, [10, 10, 0]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
