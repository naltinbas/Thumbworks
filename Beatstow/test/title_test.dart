import 'package:beatstow/beat/levels.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/beatland.dart';

/// The ring, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the ring lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Beatstow'), findsOneWidget);
    expect(
      find.textContaining('always come to the plain average of the throws'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('come down together. Hopeless.'), findsWidgets);
  });

  testWidgets('a juggle writes its fewest onto the ring', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Rest Beat'));
    await tester.pumpAndSettle();
    await juggleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The ring');
    expect(find.textContaining('Fewest: 10'), findsOneWidget);
  });
}
