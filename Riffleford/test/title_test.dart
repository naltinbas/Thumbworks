import 'package:flutter_test/flutter_test.dart';
import 'package:riffleford/deck/riffles.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every riffle by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Riffleford'), findsOneWidget);
    for (final riffle in Riffles.all) {
      expect(find.text(riffle.name), findsOneWidget);
      expect(
        find.textContaining(riffle.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a riffle opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Odd Cut'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a pile to drop its top card'),
      findsOneWidget,
    );
  });

  testWidgets('a dealt deck writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Odd Cut'));
    await tester.pumpAndSettle();
    await dropAll(tester, 'AAABBBBB');
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 8'), findsOneWidget);
  });
}
