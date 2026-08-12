import 'package:daisyholme/daisy/circles.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holmeland.dart';

/// The holme, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the holme lists every circle by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Daisyholme'), findsOneWidget);
    for (final circle in Circles.all) {
      expect(find.text(circle.name), findsOneWidget);
      expect(
        find.text(
          '${circle.task[0].toUpperCase()}${circle.task.substring(1)}',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('a circle opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three Friends'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap the line between two people'),
      findsOneWidget,
    );
  });

  testWidgets('a settling writes its fewest onto the holme',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three Friends'));
    await tester.pumpAndSettle();
    for (var pair = 0; pair < 3; pair++) {
      await tapWire(tester, pair);
    }
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The holme');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
