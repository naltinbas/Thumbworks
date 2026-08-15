import 'package:flutter_test/flutter_test.dart';
import 'package:framley/wall/levels.dart';

import 'support/fonts.dart';
import 'support/wallland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every wall by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Framley'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a wall opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Last Five'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Take a frame from the tray and tap the wall'),
      findsOneWidget,
    );
  });

  testWidgets('a hanging writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Last Five'));
    await tester.pumpAndSettle();
    await hang(tester, 4, 18, 14);
    await hang(tester, 7, 15, 18);
    await hang(tester, 1, 22, 24);
    await hang(tester, 9, 23, 24);
    await hang(tester, 8, 15, 25);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 5'), findsOneWidget);
  });
}
