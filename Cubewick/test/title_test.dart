import 'package:flutter_test/flutter_test.dart';
import 'package:cubewick/hex/levels.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every hexagon by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Cubewick'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a hexagon opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Box'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a triangle, then one beside it'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Box'));
    await tester.pumpAndSettle();
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
