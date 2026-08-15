import 'package:flutter_test/flutter_test.dart';
import 'package:kitewick/kite/levels.dart';

import 'support/fonts.dart';
import 'support/kiteland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Kitewick'), findsOneWidget);
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
    await tester.tap(find.text('The Two'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two cells side by side to lay a slate over them'),
      findsOneWidget,
    );
  });

  testWidgets('a slating writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two'));
    await tester.pumpAndSettle();
    await layAll(tester, [(0, 1), (2, 3)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
