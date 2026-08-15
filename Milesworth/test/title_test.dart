import 'package:flutter_test/flutter_test.dart';
import 'package:milesworth/lane/levels.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every lane by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Milesworth'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a lane opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Fifteen'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a milestone for each end'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Fifteen'));
    await tester.pumpAndSettle();
    await markAll(tester, [4, 6]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
