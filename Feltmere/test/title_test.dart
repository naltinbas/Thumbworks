import 'package:flutter_test/flutter_test.dart';
import 'package:feltmere/hat/levels.dart';

import 'support/fonts.dart';
import 'support/hatland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Feltmere'), findsOneWidget);
    expect(find.textContaining('Three villagers in black or white hats'),
        findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Half'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap a cell to set what that villager says'),
        findsOneWidget);
  });

  testWidgets('an agreement writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Half'));
    await tester.pumpAndSettle();
    await agreeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
