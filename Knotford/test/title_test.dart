import 'package:flutter_test/flutter_test.dart';
import 'package:knotford/rope/ropes.dart';

import 'support/fonts.dart';
import 'support/knotland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every rope by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Knotford'), findsOneWidget);
    for (final rope in Ropes.all) {
      expect(find.text(rope.name), findsOneWidget);
      expect(
        find.textContaining(rope.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a rope opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Twelve'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap knots on the rope'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Twelve'));
    await tester.pumpAndSettle();
    await standAll(tester, [3, 7]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
