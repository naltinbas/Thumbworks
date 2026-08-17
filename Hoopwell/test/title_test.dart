import 'package:flutter_test/flutter_test.dart';
import 'package:hoopwell/hoop/levels.dart';

import 'support/fonts.dart';
import 'support/hoopland.dart';

/// The hoop, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the hoop lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Hoopwell'), findsOneWidget);
    expect(
      find.textContaining('the lamps can never fall below the floor'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('4 lamps light. Hopeless.'), findsOneWidget);
  });

  testWidgets('a landing writes its fewest onto the hoop', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Six'));
    await tester.pumpAndSettle();
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The hoop');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
