import 'package:flutter_test/flutter_test.dart';
import 'package:mootbury/moot/levels.dart';

import 'support/fonts.dart';
import 'support/mootland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every moot by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Mootbury'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a moot opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Alabama Paradox'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Size the moot: each hamlet shows its quota'),
      findsOneWidget,
    );
  });

  testWidgets('a sizing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Alabama Paradox'));
    await tester.pumpAndSettle();
    await sizeTo(tester, 10);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
