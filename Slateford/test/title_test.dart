import 'package:flutter_test/flutter_test.dart';
import 'package:slateford/slate/levels.dart';

import 'support/fonts.dart';
import 'support/slateland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every level by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Slateford'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a level opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Open Slate'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a cell to mark it'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Open Slate'));
    await tester.pumpAndSettle();
    await playByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 5'), findsOneWidget);
  });
}
