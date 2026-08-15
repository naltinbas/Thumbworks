import 'package:flutter_test/flutter_test.dart';
import 'package:wardsby/parish/levels.dart';

import 'support/fonts.dart';
import 'support/parishland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every parish by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Wardsby'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a parish opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Sweep'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a household to move it round the five wards'),
      findsOneWidget,
    );
  });

  testWidgets('a drawing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Sweep'));
    await tester.pumpAndSettle();
    await draw(tester, [for (var c = 0; c < 25; c++) c % 5]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: '), findsOneWidget);
  });
}
