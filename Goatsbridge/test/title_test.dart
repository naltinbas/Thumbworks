import 'package:flutter_test/flutter_test.dart';
import 'package:goatsbridge/stall/levels.dart';

import 'support/fonts.dart';
import 'support/stallland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every stall by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Goatsbridge'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a stall opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('Two in Three'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Set the doors and how many goats the host opens'),
      findsOneWidget,
    );
  });

  testWidgets('a setting writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('Two in Three'));
    await tester.pumpAndSettle();
    await set(tester, 'policy');
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
