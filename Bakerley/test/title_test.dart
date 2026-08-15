import 'package:flutter_test/flutter_test.dart';
import 'package:bakerley/tray/levels.dart';

import 'support/fonts.dart';
import 'support/trayland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every tray by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Bakerley'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a tray opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Pinwheel'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Take a four from the bag, Turn or Flip it'),
      findsOneWidget,
    );
  });

  testWidgets('a filling writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Pinwheel'));
    await tester.pumpAndSettle();
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
