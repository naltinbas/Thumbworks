import 'package:flutter_test/flutter_test.dart';
import 'package:oddsworth/odd/levels.dart';

import 'support/fonts.dart';
import 'support/oddland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Oddsworth'), findsOneWidget);
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
    await tester.tap(find.text('The Twenty-One'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Set the first odd number and how many follow it'),
      findsOneWidget,
    );
  });

  testWidgets('a run writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Twenty-One'));
    await tester.pumpAndSettle();
    await setDials(tester, 5, 3);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
