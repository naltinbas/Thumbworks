import 'package:flutter_test/flutter_test.dart';
import 'package:trayford/count/trays.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every tray by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Trayford'), findsOneWidget);
    for (final tray in Trays.all) {
      expect(find.text(tray.name), findsOneWidget);
      expect(
        find.textContaining(tray.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a tray opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Old Count'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a slot to fill the tray up to it'),
      findsOneWidget,
    );
  });

  testWidgets('a met asking writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Old Count'));
    await tester.pumpAndSettle();
    await tapSlot(tester, 23);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
