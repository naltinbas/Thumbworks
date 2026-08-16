import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/haltland.dart';

/// One ask on the screen, the dials stepped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the gaps so that the average wait is the fair 9 1/2 minutes'), findsOneWidget);
    expect(find.text('wait 11 1/6'), findsOneWidget);
    expect(find.text('1 2/3 over fair'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Gaps 10, 20 and 30: average wait 11 1/6 minutes, 1 2/3 over the fair 9 1/2.'), findsOneWidget);
  });

  testWidgets('the dials step the gaps, and back undoes', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'g1', 1);
    expect(state(tester).play.gaps, [11, 20, 29]);
    expect(find.text('Gaps 11, 20 and 29: average wait 10 17/20 minutes, 1 7/20 over the fair 9 1/2.'), findsOneWidget);
    expect(find.text('wait 10 17/20'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.gaps, [10, 20, 30]);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the fair wait lands at 20, 20 and 20 and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setGaps(tester, 20, 20);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Timetabled.'), findsOneWidget);
    expect(find.text('As asked. Gaps 20, 20 and 20: average wait 9 1/2 minutes, the fair wait itself.'), findsOneWidget);
    expect(find.textContaining('Gaps 20, 20 and 20: average wait 9 1/2 minutes, by the gaps and by the minutes, the fair wait itself, the longest wait 19; one of 1 timetable of the 1,711; 10 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Timetabled.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the step, and the pointer reaches 10, 10 and 40', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Step the second gap down.'), findsOneWidget);
    expect(state(tester).pointing, ('g2', -1));
    await gapsByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.gaps, [10, 10, 40]);
    expect(state(tester).play.moves, 10);
    expect(find.text('As asked. Gaps 10, 10 and 40: average wait 14 1/2 minutes, 5 over the fair 9 1/2.'), findsOneWidget);
    expect(find.textContaining('the longest wait 39; one of 3 timetables of the 1,711; 10 taps.'), findsOneWidget);
  });

  testWidgets('the quarter hour lands on the way to 5, 5 and 50', (tester) async {
    await open(tester, which: 2);
    await setGaps(tester, 5, 5);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.gaps, [5, 14, 41]);
    expect(find.text('As asked. Gaps 5, 14 and 41: average wait 15 7/20 minutes, 5 17/20 over the fair 9 1/2.'), findsOneWidget);
    expect(find.textContaining('the longest wait 40; one of 555 timetables of the 1,711; 11 taps.'), findsOneWidget);
  });

  testWidgets('the worst timetable, at 1, 1 and 58', (tester) async {
    await open(tester, which: 3);
    await setGaps(tester, 1, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Gaps 1, 1 and 58: average wait 27 11/20 minutes, 18 1/20 over the fair 9 1/2.'), findsOneWidget);
    expect(find.textContaining('the longest wait 57; one of 3 timetables of the 1,711'), findsOneWidget);
  });

  testWidgets('a timetable short of the ask says its wait', (tester) async {
    await open(tester, which: 1);
    await setGaps(tester, 10, 15);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Gaps 10, 15 and 35: average wait 12 5/12 minutes, 2 11/12 over the fair 9 1/2.'), findsOneWidget);
    expect(find.text('2 11/12 over fair'), findsOneWidget);
  });

  testWidgets('the short wait admits it at the fair timetable', (tester) async {
    await open(tester, which: 4);
    await setGaps(tester, 20, 20);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Never under, always.'), findsOneWidget);
    expect(find.text('Gaps 20, 20 and 20: average wait 9 1/2 minutes, the fair wait itself. Never under, whatever the gaps.'), findsOneWidget);
    expect(find.textContaining('Here the gaps 20, 20 and 20 wait 9 1/2, the fair wait itself, as low as it goes.'), findsOneWidget);
  });

  testWidgets('the why tells Feller and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Feller set the paradox down in 1966'), findsOneWidget);
    expect(find.textContaining('waited out in full'), findsOneWidget);
  });
}
