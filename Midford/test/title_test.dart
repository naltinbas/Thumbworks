import 'package:flutter_test/flutter_test.dart';
import 'package:midford/peg/cordings.dart';

import 'support/fonts.dart';
import 'support/fordland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every cording by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Midford'), findsOneWidget);
    for (final cording in Cordings.all) {
      expect(find.text(cording.name), findsOneWidget);
      expect(
        find.textContaining(cording.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a cording opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Cross Cords'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap holes to set the pegs in order'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Cross Cords'));
    await tester.pumpAndSettle();
    await setPegs(tester, [(2, 0), (4, 2), (2, 4), (0, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
