import 'package:flutter_test/flutter_test.dart';
import 'package:thirdwell/deal/walks.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every walk by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Thirdwell'), findsOneWidget);
    for (final walk in Walks.all) {
      expect(find.text(walk.name), findsOneWidget);
      expect(
        find.textContaining(walk.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a walk opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Top'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap where the gold column goes'),
      findsOneWidget,
    );
  });

  testWidgets('a walk writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Top'));
    await tester.pumpAndSettle();
    await gatherAll(tester, [0, 0, 0]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
