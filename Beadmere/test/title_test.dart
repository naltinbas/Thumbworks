import 'package:flutter_test/flutter_test.dart';
import 'package:beadmere/strip/levels.dart';

import 'support/fonts.dart';
import 'support/stripland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Beadmere'), findsOneWidget);
    expect(find.textContaining('A strip of light and dark beads'),
        findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three and the Five'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap a bead to turn it over'), findsOneWidget);
  });

  testWidgets('a strip writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three and the Five'));
    await tester.pumpAndSettle();
    await stringByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
