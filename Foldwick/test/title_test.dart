import 'package:flutter_test/flutter_test.dart';
import 'package:foldwick/plank/crossings.dart';

import 'support/foldland.dart';
import 'support/fonts.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every crossing by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Foldwick'), findsOneWidget);
    for (final crossing in Crossings.all) {
      expect(find.text(crossing.name), findsOneWidget);
      expect(
        find.textContaining(crossing.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a crossing opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The One and One'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a beast to move it forward'),
      findsOneWidget,
    );
  });

  testWidgets('a crossing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The One and One'));
    await tester.pumpAndSettle();
    await moveAll(tester, [0, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
