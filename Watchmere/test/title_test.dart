import 'package:flutter_test/flutter_test.dart';
import 'package:watchmere/watch/meres.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// The wall, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the wall lists every mere by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Watchmere'), findsOneWidget);
    for (final mere in Meres.all) {
      expect(find.text(mere.name), findsOneWidget);
      expect(
        find.textContaining(mere.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a mere opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three Watches'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a watch\'s left half'),
      findsOneWidget,
    );
  });

  testWidgets('a dialling writes its fewest onto the wall',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three Watches'));
    await tester.pumpAndSettle();
    await dialByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The mere');
    expect(find.textContaining('Fewest: '), findsOneWidget);
  });
}
