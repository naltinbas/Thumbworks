import 'package:flutter_test/flutter_test.dart';
import 'package:kerbwell/yard/yards.dart';

import 'support/fonts.dart';
import 'support/kerbland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every yard by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Kerbwell'), findsOneWidget);
    for (final yard in Yards.all) {
      expect(find.text(yard.name), findsOneWidget);
      expect(
        find.textContaining(yard.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a yard opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Square Yard'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a cell to lay a slab'),
      findsOneWidget,
    );
  });

  testWidgets('a laying writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Square Yard'));
    await tester.pumpAndSettle();
    await layAll(tester, [(1, 1), (2, 1), (1, 2), (2, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
