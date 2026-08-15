import 'package:flutter_test/flutter_test.dart';
import 'package:laneford/green/levels.dart';

import 'support/fonts.dart';
import 'support/greenland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every green by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Laneford'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a green opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Hamlets'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a hamlet to take it up and a bare point to stand it there'),
      findsOneWidget,
    );
  });

  testWidgets('a clear green writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Hamlets'));
    await tester.pumpAndSettle();
    await moveHamlet(tester, 1, 1, 1);
    await moveHamlet(tester, 3, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
