import 'package:beamsworth/beam/worths.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yard.dart';

/// The yard, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the yard lists every worth by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Beamsworth'), findsOneWidget);
    for (final worth in Worths.all) {
      expect(find.text(worth.name), findsOneWidget);
      expect(find.textContaining(worth.task), findsOneWidget);
    }
  });

  testWidgets('a worth opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Six'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a weight to choose it'),
      findsOneWidget,
    );
  });

  testWidgets('a weighing writes its fewest onto the yard',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three'));
    await tester.pumpAndSettle();
    await chooseAll(tester, const [1, 2, 4]);
    await press(tester, 'The yard');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
