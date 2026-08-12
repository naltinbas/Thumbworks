import 'package:addlemoor/sum/moors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/moorland.dart';

/// The moorland, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the moorland lists every moor by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Addlemoor'), findsOneWidget);
    for (final moor in Moors.all) {
      expect(find.text(moor.name), findsOneWidget);
      expect(find.textContaining(moor.task), findsOneWidget);
    }
  });

  testWidgets('a moor opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Thirteen'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a stone to swap its paint'),
      findsOneWidget,
    );
  });

  testWidgets('a painting writes its fewest onto the moorland',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four'));
    await tester.pumpAndSettle();
    await paintAll(tester, const [0, 1, 1, 0]);
    await press(tester, 'The moor');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
