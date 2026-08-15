import 'package:flutter_test/flutter_test.dart';
import 'package:cutlassby/deck/levels.dart';

import 'support/fonts.dart';
import 'support/byland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every supper by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Cutlassby'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a supper opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('Two Pirates'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a pirate to give him a coin'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('Two Pirates'));
    await tester.pumpAndSettle();
    await press(tester, 'Vote');
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 0'), findsOneWidget);
  });
}
