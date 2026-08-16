import 'package:flutter_test/flutter_test.dart';
import 'package:rootley/root/levels.dart';

import 'support/fonts.dart';
import 'support/rootland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Rootley'), findsOneWidget);
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
    await tester.tap(find.text('The Seven'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Turn the base dial, a step a tap, and watch the base walk the hours'),
      findsOneWidget,
    );
  });

  testWidgets('a walk home writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Seven'));
    await tester.pumpAndSettle();
    await setDials(tester, 7, 3);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
