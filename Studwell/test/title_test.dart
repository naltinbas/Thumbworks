import 'package:flutter_test/flutter_test.dart';
import 'package:studwell/court/courts.dart';
import 'package:studwell/court/rules.dart';

import 'support/fonts.dart';
import 'support/studland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every court by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Studwell'), findsOneWidget);
    for (final court in Courts.all) {
      expect(find.text(court.name), findsOneWidget);
      expect(
        find.textContaining(court.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a court opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Corner Well'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap three flags in an L'),
      findsOneWidget,
    );
  });

  testWidgets('a paving writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Corner Well'));
    await tester.pumpAndSettle();
    for (final elbow in Rules(4, 0).quartering()!) {
      await lay(tester, elbow);
    }
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 5'), findsOneWidget);
  });
}
