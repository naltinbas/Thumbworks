import 'package:flutter_test/flutter_test.dart';
import 'package:wedgeworth/wedge/levels.dart';

import 'support/fonts.dart';
import 'support/wedgeland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Wedgeworth'), findsOneWidget);
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
    await tester.tap(find.text('The Cube'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a number to set the sides of the faces'),
      findsOneWidget,
    );
  });

  testWidgets('a closing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Cube'));
    await tester.pumpAndSettle();
    await tapDial(tester, 1, 3);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
