import 'package:flutter_test/flutter_test.dart';
import 'package:tosswell/toss/levels.dart';

import 'support/fonts.dart';
import 'support/tossland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Tosswell'), findsOneWidget);
    expect(
      find.textContaining(
          'The purse averages nothing, whichever rule you write'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('walks away ahead. Hopeless.'), findsOneWidget);
  });

  testWidgets('a rule writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('Ahead More Than Half'));
    await tester.pumpAndSettle();
    await mark(tester, (1, 1));
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
