import 'package:flutter_test/flutter_test.dart';
import 'package:haltwick/wait/levels.dart';

import 'support/fonts.dart';
import 'support/haltland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Haltwick'), findsOneWidget);
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
    await tester.tap(find.text('The Fair Wait'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Step the first two gaps up and down'),
      findsOneWidget,
    );
  });

  testWidgets('a timetable writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Fair Wait'));
    await tester.pumpAndSettle();
    await setGaps(tester, 20, 20);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 10'), findsOneWidget);
  });
}
