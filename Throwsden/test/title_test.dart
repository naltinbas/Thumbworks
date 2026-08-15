import 'package:flutter_test/flutter_test.dart';
import 'package:throwsden/fair/levels.dart';

import 'support/fonts.dart';
import 'support/denland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every yard by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Throwsden'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a yard opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a wrestler on the bench'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four'));
    await tester.pumpAndSettle();
    await stepAll(tester, [0, 3, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
