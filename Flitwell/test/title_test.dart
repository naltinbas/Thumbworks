import 'package:flitwell/flit/levels.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/flitland.dart';

/// The lane, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the lane lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Flitwell'), findsOneWidget);
    expect(
      find.textContaining('Exactly one lane of swaps is one that no group '
          'can better'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(
        find.textContaining('no group can better. Hopeless.'), findsOneWidget);
  });

  testWidgets('a landing writes its fewest onto the lane', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Willing Lane'));
    await tester.pumpAndSettle();
    await landByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The lane');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
