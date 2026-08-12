import 'package:flutter_test/flutter_test.dart';
import 'package:wantley/wish/wishes.dart';

import 'support/fonts.dart';
import 'support/greenland.dart';

/// The green, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the green lists every wish list by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Wantley'), findsOneWidget);
    for (final wish in Wishes.all) {
      expect(find.text(wish.name), findsOneWidget);
      expect(
        find.text(
          '${wish.task[0].toUpperCase()}${wish.task.substring(1)}',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('a wish list opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Ones'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap the line between two farms'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the green',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Ones'));
    await tester.pumpAndSettle();
    await tapPath(tester, 0);
    await tapPath(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The green');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
