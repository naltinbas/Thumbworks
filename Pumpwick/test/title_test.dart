import 'package:flutter_test/flutter_test.dart';
import 'package:pumpwick/lane/levels.dart';

import 'support/fonts.dart';
import 'support/laneland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Pumpwick'), findsOneWidget);
    expect(find.textContaining('Houses along a lane and a pump'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Five Houses'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap along the lane to roll the pump'),
        findsOneWidget);
  });

  testWidgets('a standing writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Five Houses'));
    await tester.pumpAndSettle();
    await rollAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 5'), findsOneWidget);
  });
}
