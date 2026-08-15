import 'package:flutter_test/flutter_test.dart';
import 'package:gablewick/gable/levels.dart';

import 'support/fonts.dart';
import 'support/gableland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Gablewick'), findsOneWidget);
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
    await tester.tap(find.text('The Right Angle'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Set the three sides a step a tap and see the gable and its area'),
      findsOneWidget,
    );
  });

  testWidgets('a framing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Right Angle'));
    await tester.pumpAndSettle();
    await turn(tester, 'third', -1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
