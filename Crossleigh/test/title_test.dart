import 'package:flutter_test/flutter_test.dart';
import 'package:crossleigh/cut/levels.dart';

import 'support/fonts.dart';
import 'support/cutland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Crossleigh'), findsOneWidget);
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
    await tester.tap(find.text('The Middle Cut'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two pegs of the field and the line through them cuts the triangle'),
      findsOneWidget,
    );
  });

  testWidgets('a cut writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Middle Cut'));
    await tester.pumpAndSettle();
    await setPegs(tester, [(6, 0), (0, 4)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
