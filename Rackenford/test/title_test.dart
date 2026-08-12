import 'package:flutter_test/flutter_test.dart';
import 'package:rackenford/rack/pantries.dart';

import 'support/fonts.dart';
import 'support/pantryland.dart';

/// The larder, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the larder lists every pantry by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Rackenford'), findsOneWidget);
    for (final pantry in Pantries.all) {
      expect(find.text(pantry.name), findsOneWidget);
      expect(
        find.textContaining(pantry.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a pantry opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Six on Three'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a jar to lift it'),
      findsOneWidget,
    );
  });

  testWidgets('a racking writes its fewest onto the larder',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Six on Three'));
    await tester.pumpAndSettle();
    await rackByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The pantry');
    expect(find.textContaining('Fewest: '), findsOneWidget);
  });
}
