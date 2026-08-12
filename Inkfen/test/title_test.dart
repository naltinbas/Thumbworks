import 'package:flutter_test/flutter_test.dart';
import 'package:inkfen/ink/lines.dart';

import 'support/fenland.dart';
import 'support/fonts.dart';

/// The fen, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the fen lists every line by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Inkfen'), findsOneWidget);
    for (final line in Lines.all) {
      expect(find.text(line.name), findsOneWidget);
      expect(
        find.textContaining(line.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a line opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two-Ink Path'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a string to dip it'),
      findsOneWidget,
    );
  });

  testWidgets('an inking writes its fewest onto the fen',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two-Ink Path'));
    await tester.pumpAndSettle();
    await tapString(tester, 0);
    await dipTo(tester, 1, 2);
    await tapString(tester, 2);
    await dipTo(tester, 3, 2);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The fen');
    expect(find.textContaining('Fewest: 6'), findsOneWidget);
  });
}
