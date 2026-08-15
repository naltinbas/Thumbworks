import 'package:flutter_test/flutter_test.dart';
import 'package:cellarwick/glass/levels.dart';

import 'support/fonts.dart';
import 'support/glassland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Cellarwick'), findsOneWidget);
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
    await tester.tap(find.text('The One Unit'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Set the two glasses and the spoon a step a tap'),
      findsOneWidget,
    );
  });

  testWidgets('a pouring writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Half and Half'));
    await tester.pumpAndSettle();
    await setDials(tester, 10, 1, 1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 9'), findsOneWidget);
  });
}
