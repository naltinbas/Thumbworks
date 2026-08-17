import 'package:flutter_test/flutter_test.dart';
import 'package:glintmere/glint/levels.dart';

import 'support/fonts.dart';
import 'support/glintland.dart';

/// The mirror, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the mirror lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Glintmere'), findsOneWidget);
    expect(
      find.textContaining('the angle in matches the angle out'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('within 9 paces. Hopeless.'), findsOneWidget);
  });

  testWidgets('a catch writes its fewest onto the mirror', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Thirteen'));
    await tester.pumpAndSettle();
    await catchByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The mirror');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
