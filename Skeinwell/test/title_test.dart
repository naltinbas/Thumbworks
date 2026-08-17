import 'package:flutter_test/flutter_test.dart';
import 'package:skeinwell/skein/levels.dart';

import 'support/fonts.dart';
import 'support/skeinland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Skeinwell'), findsOneWidget);
    expect(
      find.textContaining('However the lanes lie, the shares add to four'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Full Skein'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a lane to lay it and tap it again to lift it'),
      findsOneWidget,
    );
  });

  testWidgets('a village writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Half Lane'));
    await tester.pumpAndSettle();
    await setVillage(tester, [0, 1, 3, 6, 8, 9]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
