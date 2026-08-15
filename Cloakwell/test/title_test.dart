import 'package:flutter_test/flutter_test.dart';
import 'package:cloakwell/rail/levels.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every rail by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Cloakwell'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a rail opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Askew'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap the mark between two coats'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Askew'));
    await tester.pumpAndSettle();
    await swapAll(tester, [0, 2]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
