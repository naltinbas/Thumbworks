import 'package:flutter_test/flutter_test.dart';
import 'package:ledgeworth/stack/levels.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every stack by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Ledgeworth'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a stack opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The One'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap the right half of a book'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The One'));
    await tester.pumpAndSettle();
    await lean(tester, [12]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 12'), findsOneWidget);
  });
}
