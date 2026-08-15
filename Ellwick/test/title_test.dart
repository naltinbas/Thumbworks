import 'package:flutter_test/flutter_test.dart';
import 'package:ellwick/rung/levels.dart';

import 'support/fonts.dart';
import 'support/rungland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Ellwick'), findsOneWidget);
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
    await tester.tap(find.text('The One Over'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Set the side and the diagonal a step a tap, or climb the ladder a rung'),
      findsOneWidget,
    );
  });

  testWidgets('a measure writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Over'));
    await tester.pumpAndSettle();
    await turn(tester, 'diagonal', -1);
    await climb(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
