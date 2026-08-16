import 'package:flutter_test/flutter_test.dart';
import 'package:sunderby/part/levels.dart';

import 'support/fonts.dart';
import 'support/partland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Sunderby'), findsOneWidget);
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
    await tester.tap(find.text('The Ten'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a size on the shelf to lay a part of that size'),
      findsOneWidget,
    );
  });

  testWidgets('a sundering writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Ten'));
    await tester.pumpAndSettle();
    await addAll(tester, [4, 3, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
