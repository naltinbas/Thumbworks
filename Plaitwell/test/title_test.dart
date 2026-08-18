import 'package:flutter_test/flutter_test.dart';
import 'package:plaitwell/plait/levels.dart';

import 'support/fonts.dart';
import 'support/plaitland.dart';

/// The rope walk, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the rope walk lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Plaitwell'), findsOneWidget);
    expect(find.textContaining('says what knot you are holding'),
        findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(
      find.text('Paint the 4 crossings of the figure eight so each shows one '
          'colour or three, and use all three. Hopeless.'),
      findsOneWidget,
    );
  });

  testWidgets('a painted plait writes its fewest onto the rope walk',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Short Plait'));
    await tester.pumpAndSettle();
    await paintByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.taps, 3);
    await press(tester, 'The rope walk');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
