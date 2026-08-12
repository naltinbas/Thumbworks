import 'package:flutter_test/flutter_test.dart';
import 'package:stitchfen/thread/rows.dart';

import 'support/fonts.dart';
import 'support/sampler.dart';

/// The fen, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the fen lists every row by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Stitchfen'), findsOneWidget);
    for (final row in Rows.all) {
      expect(find.text(row.name), findsOneWidget);
      expect(find.textContaining(row.task), findsOneWidget);
    }
  });

  testWidgets('a row opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Eight'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a stitch to flip its thread'),
      findsOneWidget,
    );
  });

  testWidgets('a threading writes its fewest onto the fen',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Six'));
    await tester.pumpAndSettle();
    await threadAll(tester, 'RRBBRR');
    await press(tester, 'The fen');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
