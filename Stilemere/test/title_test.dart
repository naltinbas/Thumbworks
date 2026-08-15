import 'package:flutter_test/flutter_test.dart';
import 'package:stilemere/field/levels.dart';

import 'support/fonts.dart';
import 'support/stileland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every field by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Stilemere'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a field opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Stile'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap the junction to the right or above'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Stile'));
    await tester.pumpAndSettle();
    await stepAll(tester, [(1, 0), (1, 1), (1, 2), (2, 2), (3, 2), (3, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 6'), findsOneWidget);
  });
}
