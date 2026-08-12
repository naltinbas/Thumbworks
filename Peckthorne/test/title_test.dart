import 'package:flutter_test/flutter_test.dart';
import 'package:peckthorne/peck/flocks.dart';

import 'support/fonts.dart';
import 'support/yardring.dart';

/// The yard, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the yard lists every flock by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Peckthorne'), findsOneWidget);
    for (final flock in Flocks.all) {
      expect(find.text(flock.name), findsOneWidget);
      expect(
        find.text(
          '${flock.task[0].toUpperCase()}${flock.task.substring(1)}',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('a flock opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Round of Three'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap an arrow to flip who pecks whom'),
      findsOneWidget,
    );
  });

  testWidgets('a crowning writes its fewest onto the yard',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Round of Three'));
    await tester.pumpAndSettle();
    await tapPair(tester, 1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The yard');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
