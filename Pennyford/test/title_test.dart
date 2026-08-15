import 'package:flutter_test/flutter_test.dart';
import 'package:pennyford/ring/levels.dart';

import 'support/fonts.dart';
import 'support/ringland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Pennyford'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Size the middle coin and the ring coins a step a tap'),
      findsOneWidget,
    );
  });

  testWidgets('a ring writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four'));
    await tester.pumpAndSettle();
    await setDials(tester, 1, 2);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
