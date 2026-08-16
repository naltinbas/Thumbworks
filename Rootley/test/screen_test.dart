import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/rootland.dart';

/// One ask on the screen, walked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the base so its walk touches every hour of the seven-hour clock but 0'), findsOneWidget);
    expect(find.text('base 1'), findsOneWidget);
    expect(find.text('clock 7'), findsNothing);
    expect(find.text('hours 1'), findsOneWidget);
    expect(find.text('home in 1'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Base 1 on the seven-hour clock stays put at 1, home before it starts.'), findsOneWidget);
  });

  testWidgets('a free ask shows both dials', (tester) async {
    await open(tester, which: 1);
    expect(find.text('clock 12'), findsOneWidget);
    expect(find.text('base 1'), findsOneWidget);
    expect(find.textContaining('Turn the dials, a step a tap'), findsOneWidget);
  });

  testWidgets('a tap turns the base and back undoes it', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'base', 1);
    expect(state(tester).play.base, 2);
    expect(find.text('base 2'), findsOneWidget);
    expect(find.text('hours 3'), findsOneWidget);
    expect(find.text('home in 3'), findsOneWidget);
    expect(find.text('Base 2 on the seven-hour clock walks 1, 2 and 4 and comes home on step 3, touching 3 of the 6 hours a base can.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.base, 1);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the seven lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setDials(tester, 7, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Home.'), findsOneWidget);
    expect(find.text('As asked. Base 3 on the seven-hour clock walks 1, 3, 2, 6, 4 and 5 and comes home on step 6, touching every hour a base can, 6 of them.'), findsOneWidget);
    expect(find.textContaining('Base 3 on the seven-hour clock walks 1, 3, 2, 6, 4 and 5 and comes home on step 6; one of 2 bases of its 6; 2 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Home.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('a base sharing a factor never comes home, and says so', (tester) async {
    await open(tester, which: 4);
    await turn(tester, 'base', 1);
    expect(find.text('never home'), findsOneWidget);
    expect(find.text('hours 4'), findsOneWidget);
    expect(find.text('Base 2 on the eight-hour clock walks 1, 2, 4 and 0 and stops at 0, never home: 2 and 8 share the factor 2.'), findsOneWidget);
  });

  testWidgets('show me names the dial and the way, and the pointer lands the fourth home', (tester) async {
    await open(tester, which: 1);
    await turn(tester, 'base', 1);
    expect(find.text('Base 2 on the twelve-hour clock walks 1, 2, 4 and 8 and falls back to 4, never home: 2 and 12 share the factor 2.'), findsOneWidget);
    await press(tester, 'Show me');
    expect(find.text('Turn the clock down.'), findsOneWidget);
    expect(state(tester).pointing, (0, -1));
    await walkByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.clock, state(tester).play.base, state(tester).play.moves), (5, 2, 8));
    expect(find.text('As asked. Base 2 on the five-hour clock walks 1, 2, 4 and 3 and comes home on step 4, touching every hour a base can, 4 of them.'), findsOneWidget);
    expect(find.textContaining('one of 20 settings of the 275; 8 taps.'), findsOneWidget);
  });

  testWidgets('the full round wants ten hours or more: the seven-hour clock does not do', (tester) async {
    await open(tester, which: 2);
    await setDials(tester, 7, 3);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Base 3 on the seven-hour clock walks 1, 3, 2, 6, 4 and 5 and comes home on step 6, touching every hour a base can, 6 of them.'), findsOneWidget);
    await setDials(tester, 11, 2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Base 2 on the eleven-hour clock walks 1, 2, 4, 8, 5, 10, 9, 7, 3 and 6 and comes home on step 10, touching every hour a base can, 10 of them.'), findsOneWidget);
    expect(find.textContaining('one of 32 settings of the 275; 12 taps.'), findsOneWidget);
  });

  testWidgets('the nine lands on base 2', (tester) async {
    await open(tester, which: 3);
    await turn(tester, 'base', 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Base 2 on the nine-hour clock walks 1, 2, 4, 8, 7 and 5 and comes home on step 6, touching every hour a base can, 6 of them.'), findsOneWidget);
    expect(find.textContaining('one of 2 bases of its 8; 1 tap.'), findsOneWidget);
  });

  testWidgets('the eight admits it once every base is tried', (tester) async {
    await open(tester, which: 4);
    await setDials(tester, 8, 7);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Odd squares are 1.'), findsOneWidget);
    expect(find.text('No base of eight touches more than two odd hours: every odd square is 1 on the eight-hour clock, 1, 9, 25 and 49.'), findsOneWidget);
    expect(find.textContaining('Eight has no full base. It never will'), findsOneWidget);
    expect(find.textContaining('the sweep of the seven bases finds none touching more than two'), findsOneWidget);
  });

  testWidgets('the why tells Euler, Gauss and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Gauss proved in 1801'), findsOneWidget);
    expect(find.textContaining('walked in full'), findsOneWidget);
  });
}
