import 'package:flutter_test/flutter_test.dart';
import 'package:shortcombe/road/levels.dart';

import 'support/fonts.dart';
import 'support/roadland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Shortcombe'), findsOneWidget);
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
    await tester.tap(find.text('The Helpful Shortcut'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Turn the crowd up or down, two hundred a tap'),
      findsOneWidget,
    );
  });

  testWidgets('a settling writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Helpful Shortcut'));
    await tester.pumpAndSettle();
    await toggle(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
