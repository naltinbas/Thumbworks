import 'package:flutter_test/flutter_test.dart';
import 'package:loafham/loaf/loaves.dart';

import 'support/fonts.dart';
import 'support/hamland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every share by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Loafham'), findsOneWidget);
    for (final loaf in Loaves.all) {
      expect(find.text(loaf.name), findsOneWidget);
      expect(
        find.textContaining(loaf.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a share opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two of Three'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a cut to take it'),
      findsOneWidget,
    );
  });

  testWidgets('a cutting writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two of Three'));
    await tester.pumpAndSettle();
    await takeAll(tester, [2, 6]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
