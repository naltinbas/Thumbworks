import 'package:dealstone/deal/handfuls.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/stoneland.dart';

/// The stone, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the stone lists every handful by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Dealstone'), findsOneWidget);
    for (final handful in Handfuls.all) {
      expect(find.text(handful.name), findsOneWidget);
      expect(
        find.textContaining(handful.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a handful opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Stair of Six'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a slot to drop a stone'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the stone',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Stair of Six'));
    await tester.pumpAndSettle();
    await dealByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The stone');
    expect(find.textContaining('Fewest: '), findsOneWidget);
  });
}
