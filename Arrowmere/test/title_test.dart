import 'package:flutter_test/flutter_test.dart';
import 'package:arrowmere/ways/levels.dart';

import 'support/fonts.dart';
import 'support/wayland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Arrowmere'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
    expect(find.textContaining('every street of the square'), findsWidgets);
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Square'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap a street to turn its arrow about'),
        findsOneWidget);
  });

  testWidgets('a landing writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Square'));
    await tester.pumpAndSettle();
    await pointAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
