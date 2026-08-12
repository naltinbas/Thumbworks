import 'package:coursewell/course/yards.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// The yardland, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the yardland lists every yard by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Coursewell'), findsOneWidget);
    for (final yard in Yards.all) {
      expect(find.text(yard.name), findsOneWidget);
      expect(
        find.textContaining(yard.task.substring(1)),
        findsOneWidget,
      );
    }
  });

  testWidgets('a yard opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Square'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two cells side by side'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the yardland',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four Square'));
    await tester.pumpAndSettle();
    for (var brick = 0; brick < 8; brick++) {
      await brickOver(tester, (brick * 2, brick * 2 + 1));
    }
    await press(tester, 'The yards');
    expect(find.textContaining('Fewest: 8'), findsOneWidget);
  });
}
