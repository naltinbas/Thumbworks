import 'package:flutter_test/flutter_test.dart';
import 'package:pippinstow/sight/levels.dart';

import 'support/fonts.dart';
import 'support/orchardland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Pippinstow'), findsOneWidget);
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
    await tester.tap(find.text('The Far Row'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a tree and the line of sight from the gate'),
      findsOneWidget,
    );
  });

  testWidgets('a tree writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Far Row'));
    await tester.pumpAndSettle();
    await tapTree(tester, (1, 10));
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
