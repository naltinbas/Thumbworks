import 'package:flutter_test/flutter_test.dart';
import 'package:chimewell/coil/levels.dart';

import 'support/fonts.dart';
import 'support/coilland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Chimewell'), findsOneWidget);
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
    await tester.tap(find.text('The Whole Tone'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Turn the dials, a fifth or an octave a tap'),
      findsOneWidget,
    );
  });

  testWidgets('a sounding writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Whole Tone'));
    await tester.pumpAndSettle();
    await setDials(tester, 2, -1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
