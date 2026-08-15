import 'package:flutter_test/flutter_test.dart';
import 'package:watchcombe/yard/levels.dart';

import 'support/fonts.dart';
import 'support/combeland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every supper by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Watchcombe'), findsOneWidget);
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
    await tester.tap(find.text('The Four Yard'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a flag to post a watchman'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Yard'));
    await tester.pumpAndSettle();
    await tapAll(tester, [5, 6, 9, 10]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
