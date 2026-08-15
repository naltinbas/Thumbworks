import 'package:flutter_test/flutter_test.dart';
import 'package:queenscote/watch/levels.dart';

import 'support/fonts.dart';
import 'support/watchland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Queenscote'), findsOneWidget);
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
    await tester.tap(find.text('The Four by Four'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a square to set a queen there, tap a queen to lift her'),
      findsOneWidget,
    );
  });

  testWidgets('a watch writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four by Four'));
    await tester.pumpAndSettle();
    await setAll(tester, [0, 10]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
