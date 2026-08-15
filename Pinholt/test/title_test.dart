import 'package:flutter_test/flutter_test.dart';
import 'package:pinholt/board/plots.dart';

import 'support/fonts.dart';
import 'support/holtland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every plot by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Pinholt'), findsOneWidget);
    for (final plot in Plots.all) {
      expect(find.text(plot.name), findsOneWidget);
      expect(
        find.textContaining(plot.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a plot opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Framed Four'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a hole to set a pin'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Framed Four'));
    await tester.pumpAndSettle();
    await setPins(tester, [(0, 0), (4, 0), (4, 4), (0, 4)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
