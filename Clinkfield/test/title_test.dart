import 'package:clinkfield/clink/feasts.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/feastland.dart';
import 'support/fonts.dart';

/// The field, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the field lists every feast by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Clinkfield'), findsOneWidget);
    for (final feast in Feasts.all) {
      expect(find.text(feast.name), findsOneWidget);
      expect(
        find.textContaining(feast.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a feast opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Count'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap the line between two guests'),
      findsOneWidget,
    );
  });

  testWidgets('a feasting writes its fewest onto the field',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Count'));
    await tester.pumpAndSettle();
    await feastByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The field');
    expect(find.textContaining('Fewest: '), findsOneWidget);
  });
}
