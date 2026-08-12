import 'package:flutter_test/flutter_test.dart';
import 'package:pursewell/purse/purses.dart';

import 'support/fonts.dart';
import 'support/well.dart';

/// The well, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the well lists every purse by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Pursewell'), findsOneWidget);
    for (final purse in Purses.all) {
      expect(find.text(purse.name), findsOneWidget);
      expect(find.textContaining(purse.task), findsOneWidget);
    }
  });

  testWidgets('a purse opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Thirty'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a coin to move it'),
      findsOneWidget,
    );
  });

  testWidgets('a payment writes its fewest onto the well',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Eleven'));
    await tester.pumpAndSettle();
    await payAll(tester, const [8, 3]);
    await press(tester, 'The well');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
