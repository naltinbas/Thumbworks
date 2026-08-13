import 'package:flutter_test/flutter_test.dart';
import 'package:foursworth/window/houses.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// The worth, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the worth lists every house by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Foursworth'), findsOneWidget);
    for (final house in Houses.all) {
      expect(find.text(house.name), findsOneWidget);
      expect(
        find.textContaining(house.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a house opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Turn'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a window to turn its face'),
      findsOneWidget,
    );
  });

  testWidgets('a darkening writes its fewest onto the worth',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Turn'));
    await tester.pumpAndSettle();
    for (var window = 0; window < 4; window++) {
      await tapWindow(tester, window);
    }
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The worth');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
