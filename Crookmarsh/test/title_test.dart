import 'package:crookmarsh/marsh/marshes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/marshland.dart';

/// The marshland, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the marshland lists every marsh by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Crookmarsh'), findsOneWidget);
    for (final marsh in Marshes.all) {
      expect(find.text(marsh.name), findsOneWidget);
      expect(find.textContaining(marsh.task), findsOneWidget);
    }
  });

  testWidgets('a marsh opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Full Five'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap to set or lift'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the marshland',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Crooked Four'));
    await tester.pumpAndSettle();
    await setAll(tester, const [(0, 0), (3, 0), (1, 3), (1, 1)]);
    await press(tester, 'The marsh');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
