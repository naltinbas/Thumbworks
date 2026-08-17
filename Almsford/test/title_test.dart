import 'package:almsford/alms/levels.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/almsland.dart';
import 'support/fonts.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Almsford'), findsOneWidget);
    expect(
      find.textContaining('However you share, the fullest bin never rises'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Staircase'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a fuller bin to take a measure out'),
      findsOneWidget,
    );
  });

  testWidgets('a share-out writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('Three Small Heaps'));
    await tester.pumpAndSettle();
    await shareByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
