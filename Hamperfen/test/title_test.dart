import 'package:flutter_test/flutter_test.dart';
import 'package:hamperfen/basket/fens.dart';

import 'support/fenland.dart';
import 'support/fonts.dart';

/// The fenland, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the fenland lists every fen by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Hamperfen'), findsOneWidget);
    for (final fen in Fens.all) {
      expect(find.text(fen.name), findsOneWidget);
      expect(find.textContaining(fen.task), findsOneWidget);
    }
  });

  testWidgets('a fen opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Six'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a basket to take it'),
      findsOneWidget,
    );
  });

  testWidgets('a picking writes its fewest onto the fenland',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Pair'));
    await tester.pumpAndSettle();
    await takeAll(tester, const [3, 5]);
    await press(tester, 'The fen');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
