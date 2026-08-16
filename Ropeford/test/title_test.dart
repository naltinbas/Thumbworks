import 'package:flutter_test/flutter_test.dart';
import 'package:ropeford/ford/levels.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Ropeford'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Twin Stones'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a dry stone the rope covers'),
      findsOneWidget,
    );
  });

  testWidgets('a crossing writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Twin Stones'));
    await tester.pumpAndSettle();
    await hopAlong(tester, [3, 5]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
