import 'package:flutter_test/flutter_test.dart';
import 'package:fevershaw/village/levels.dart';

import 'support/fonts.dart';
import 'support/villageland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every village by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Fevershaw'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a village opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Even Chance'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Set the fever, the test\'s catch of the ill and its alarm'),
      findsOneWidget,
    );
  });

  testWidgets('a setting writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Even Chance'));
    await tester.pumpAndSettle();
    await tapDial(tester, 0, 2);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
