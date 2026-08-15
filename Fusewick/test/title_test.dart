import 'package:flutter_test/flutter_test.dart';
import 'package:fusewick/fuse/levels.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every time by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Fusewick'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a time opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Thirty'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a fuse end to light it'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Thirty'));
    await tester.pumpAndSettle();
    await light(tester, 0, false);
    await light(tester, 0, true);
    await burn(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
