import 'package:flutter_test/flutter_test.dart';
import 'package:roundhithe/road/levels.dart';

import 'support/fonts.dart';
import 'support/parishland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Roundhithe'), findsOneWidget);
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
    await tester.tap(find.text('The Ring'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a village, then another, to lay the road between them'),
      findsOneWidget,
    );
  });

  testWidgets('a plan writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Ring'));
    await tester.pumpAndSettle();
    await layRoads(tester, ['AB', 'BC', 'CD', 'DE', 'EF', 'FA']);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 12'), findsOneWidget);
  });
}
