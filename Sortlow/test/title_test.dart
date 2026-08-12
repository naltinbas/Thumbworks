import 'package:flutter_test/flutter_test.dart';
import 'package:sortlow/mill/loads.dart';

import 'support/fonts.dart';
import 'support/lowland.dart';

/// The low, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the low lists every load by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Sortlow'), findsOneWidget);
    for (final load in Loads.all) {
      expect(find.text(load.name), findsOneWidget);
      expect(
        find.textContaining(load.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a load opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Turn'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a dial to turn its digit'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the low',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Turn'));
    await tester.pumpAndSettle();
    // 2026 to 6200: one turn out.
    await dialTo(tester, 0, 6);
    await dialTo(tester, 1, 2);
    await dialTo(tester, 2, 0);
    await dialTo(tester, 3, 0);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The low');
    expect(find.textContaining('Fewest: '), findsOneWidget);
  });
}
