import 'package:flutter_test/flutter_test.dart';
import 'package:frogmere/mere/reaches.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every reach by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Frogmere'), findsOneWidget);
    for (final reach in Reaches.all) {
      expect(find.text(reach.name), findsOneWidget);
      expect(
        find.textContaining(reach.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a reach opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The First Reach'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a frog, then an empty pad'),
      findsOneWidget,
    );
  });

  testWidgets('a reach writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The First Reach'));
    await tester.pumpAndSettle();
    await leap(tester, (0, -1), (0, 1));
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
