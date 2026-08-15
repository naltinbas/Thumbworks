import 'package:flutter_test/flutter_test.dart';
import 'package:setwick/set/dances.dart';

import 'support/fonts.dart';
import 'support/setland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every set by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Setwick'), findsOneWidget);
    for (final dance in Dances.all) {
      expect(find.text(dance.name), findsOneWidget);
      expect(
        find.textContaining(dance.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a set opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Set of Seven'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two dancers to pair them'),
      findsOneWidget,
    );
  });

  testWidgets('a set writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Set of Seven'));
    await tester.pumpAndSettle();
    await pair(tester, 2, 4);
    await pair(tester, 3, 5);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
