import 'package:flutter_test/flutter_test.dart';
import 'package:sashmoor/pane/sashes.dart';

import 'support/fonts.dart';
import 'support/moor.dart';

/// The moor, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the moor lists every sash by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Sashmoor'), findsOneWidget);
    for (final sash in Sashes.all) {
      expect(find.text(sash.name), findsOneWidget);
      expect(find.textContaining(sash.task), findsOneWidget);
    }
  });

  testWidgets('a sash opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Eight'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap to set or lift: set 8 panes'),
      findsOneWidget,
    );
  });

  testWidgets('a glazing writes its fewest onto the moor',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Casement'));
    await tester.pumpAndSettle();
    await setAll(tester, const [(0, 0), (1, 0), (2, 0), (0, 1), (1, 2)]);
    await press(tester, 'The moor');
    expect(find.textContaining('Fewest: 5'), findsOneWidget);
  });
}
