import 'package:flutter_test/flutter_test.dart';
import 'package:flagstead/hall/levels.dart';

import 'support/fonts.dart';
import 'support/hallland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Flagstead'), findsOneWidget);
    expect(find.textContaining('Four posts at the corners of a hall'),
        findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Whole Four'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap a point to stand the peg there'),
        findsOneWidget);
  });

  testWidgets('a standing writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Whole Four'));
    await tester.pumpAndSettle();
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
