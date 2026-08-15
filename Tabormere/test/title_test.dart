import 'package:flutter_test/flutter_test.dart';
import 'package:tabormere/drum/levels.dart';

import 'support/fonts.dart';
import 'support/drumland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Tabormere'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Tresillo'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a step of the ring to set a hit there'),
      findsOneWidget,
    );
  });

  testWidgets('a rhythm writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Tresillo'));
    await tester.pumpAndSettle();
    await setAll(tester, [0, 3, 6]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
