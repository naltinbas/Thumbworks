import 'package:flutter_test/flutter_test.dart';
import 'package:roostwick/roost/levels.dart';

import 'support/fonts.dart';
import 'support/roostland.dart';

/// The wood, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the wood lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Roostwick'), findsOneWidget);
    expect(
      find.textContaining('no patch of it holds more birds than hollows'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('a hollow of its own. Hopeless.'),
        findsOneWidget);
  });

  testWidgets('a settling writes its fewest onto the wood', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Thickets'));
    await tester.pumpAndSettle();
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The wood');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
