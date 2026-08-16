import 'package:flutter_test/flutter_test.dart';
import 'package:ninebury/nine/levels.dart';

import 'support/fonts.dart';
import 'support/nineland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Ninebury'), findsOneWidget);
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
    await tester.tap(find.text('The Cube Eight'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Turn the three dials, a step a tap'),
      findsOneWidget,
    );
  });

  testWidgets('a number dialled writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Cube Eight'));
    await tester.pumpAndSettle();
    await dial(tester, 8);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 8'), findsOneWidget);
  });
}
