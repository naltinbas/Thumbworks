import 'package:flutter_test/flutter_test.dart';
import 'package:knowsley/pair/levels.dart';

import 'support/fonts.dart';
import 'support/pairland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Knowsley'), findsOneWidget);
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
    await tester.tap(find.text('The Sum Then Knew'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Step the two numbers up and down'),
      findsOneWidget,
    );
  });

  testWidgets('a pair writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Product Tells'));
    await tester.pumpAndSettle();
    await turn(tester, 'x', -1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
