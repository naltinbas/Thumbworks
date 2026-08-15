import 'package:flutter_test/flutter_test.dart';
import 'package:rowsden/school/levels.dart';

import 'support/fonts.dart';
import 'support/denland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every week by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Rowsden'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a week opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Second Day'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap girls on the bench'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Second Day'));
    await tester.pumpAndSettle();
    await placeAll(tester, [0, 3, 6, 1, 4, 7, 2, 5, 8]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 9'), findsOneWidget);
  });
}
