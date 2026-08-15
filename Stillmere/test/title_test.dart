import 'package:flutter_test/flutter_test.dart';
import 'package:stillmere/mere/lightings.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every lighting by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Stillmere'), findsOneWidget);
    for (final lighting in Lightings.all) {
      expect(find.text(lighting.name), findsOneWidget);
      expect(
        find.textContaining(lighting.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a lighting opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Lights'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a spot to light or douse a lantern'),
      findsOneWidget,
    );
  });

  testWidgets('a still mere writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Lights'));
    await tester.pumpAndSettle();
    await lightAll(tester, [(1, 1), (2, 1), (1, 2), (2, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
