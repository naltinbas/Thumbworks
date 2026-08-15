import 'package:flutter_test/flutter_test.dart';
import 'package:threadwick/star/levels.dart';

import 'support/fonts.dart';
import 'support/starland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Threadwick'), findsOneWidget);
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
    await tester.tap(find.text('The Pentagram'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Set the nails round the hoop and the skip of the thread'),
      findsOneWidget,
    );
  });

  testWidgets('a threading writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Pentagram'));
    await tester.pumpAndSettle();
    await setDials(tester, 5, 2);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
