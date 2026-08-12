import 'package:fanleigh/fold/folds.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/leigh.dart';

/// The leigh, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the leigh lists every fold by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Fanleigh'), findsOneWidget);
    for (final fold in Folds.all) {
      expect(find.text(fold.name), findsOneWidget);
      expect(find.textContaining(fold.task), findsOneWidget);
    }
  });

  testWidgets('a fold opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Zigzag'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two posts to lay a hurdle'),
      findsOneWidget,
    );
  });

  testWidgets('a folding writes its fewest onto the leigh',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Pentagon'));
    await tester.pumpAndSettle();
    await layAll(tester, const [(0, 2), (0, 3)]);
    await press(tester, 'The leigh');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
