import 'package:flutter_test/flutter_test.dart';
import 'package:stubwick/ticket/levels.dart';

import 'support/fonts.dart';
import 'support/stubland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Stubwick'), findsOneWidget);
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
    await tester.tap(find.text('The Check'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Turn the five dials, round from 9 to 0 and back'),
      findsOneWidget,
    );
  });

  testWidgets('a ticket writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Check'));
    await tester.pumpAndSettle();
    await turn(tester, 4, -1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
