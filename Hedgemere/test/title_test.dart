import 'package:flutter_test/flutter_test.dart';
import 'package:hedgemere/hedge/levels.dart';

import 'support/fonts.dart';
import 'support/hedgeland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Hedgemere'), findsOneWidget);
    expect(
      find.textContaining(
          'one post is left standing at the end, or two, and never three'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Long Hedge'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Hang each post off a different one a tap at a time'),
      findsOneWidget,
    );
  });

  testWidgets('a peeling writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Middle Post'));
    await tester.pumpAndSettle();
    await setHanging(tester, [2, 3, 3, 4, 5]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
