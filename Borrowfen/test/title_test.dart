import 'package:flutter_test/flutter_test.dart';
import 'package:borrowfen/debt/villages.dart';

import 'support/fen.dart';
import 'support/fonts.dart';

/// The fen, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the fen lists every village by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Borrowfen'), findsOneWidget);
    for (final village in Villages.all) {
      expect(find.text(village.name), findsOneWidget);
      expect(find.textContaining(village.task), findsOneWidget);
    }
  });

  testWidgets('a village opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Green'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a house: settle 2 pounds'),
      findsOneWidget,
    );
  });

  testWidgets('a settlement writes its fewest onto the fen',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Lane'));
    await tester.pumpAndSettle();
    await tapHouse(tester, 1);
    await press(tester, 'The fen');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
