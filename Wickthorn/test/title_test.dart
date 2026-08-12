import 'package:flutter_test/flutter_test.dart';
import 'package:wickthorn/rope/greens.dart';

import 'support/fonts.dart';
import 'support/village.dart';

/// The village, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the village lists every green by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Wickthorn'), findsOneWidget);
    for (final green in Greens.all) {
      expect(find.text(green.name), findsOneWidget);
      expect(find.textContaining(green.task), findsOneWidget);
    }
  });

  testWidgets('a green opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Ways'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap three lanterns to rope them'),
      findsOneWidget,
    );
  });

  testWidgets('a closing writes its fewest onto the village',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The First Rope'));
    await tester.pumpAndSettle();
    await stringRope(tester, (0, 1, 2));
    await press(tester, 'The village');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
