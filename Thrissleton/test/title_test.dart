import 'package:flutter_test/flutter_test.dart';
import 'package:thrissleton/third/hands.dart';

import 'support/fonts.dart';
import 'support/letonland.dart';

/// The leton, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the leton lists every hand by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Thrissleton'), findsOneWidget);
    for (final hand in Hands.all) {
      expect(find.text(hand.name), findsOneWidget);
      expect(
        find.text(
          '${hand.task[0].toUpperCase()}${hand.task.substring(1)}',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('a hand opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Thirds'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a stone to turn its face'),
      findsOneWidget,
    );
  });

  testWidgets('a dialling writes its fewest onto the leton',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Thirds'));
    await tester.pumpAndSettle();
    await tapStone(tester, 0);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The leton');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
