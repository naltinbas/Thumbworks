import 'package:flutter_test/flutter_test.dart';
import 'package:arrowmere/ways/levels.dart';
import 'package:arrowmere/ways/rules.dart';

import 'support/fonts.dart';
import 'support/wayland.dart';

/// One ask on the screen, the streets turned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('point every street of the square'),
        findsOneWidget);
    expect(find.text('5 of 12 ways round'), findsOneWidget);
    expect(find.text('turns 0'), findsOneWidget);
    expect(
        find.text('5 of the 12 ways round are open: from B there is no way to A or D.'),
        findsOneWidget);
  });

  testWidgets('a tap turns a street about, and back undoes it', (tester) async {
    await open(tester, which: 1);
    await tapStreet(tester, 2);
    expect(state(tester).play.arrows, [false, false, false, true]);
    expect(find.text('turns 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.arrows, Rules.square.opening);
    expect(find.text('turns 0'), findsOneWidget);
  });

  testWidgets('the square goes round in two turns', (tester) async {
    await open(tester, which: 1);
    await turnAll(tester, [2, 3]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('All ways round.'), findsOneWidget);
    expect(
        find.text('Every place can be reached from every other, all 12 ways round.'),
        findsOneWidget);
    expect(
        find.textContaining('Every one of the 12 ways round is open, on 2 turns'),
        findsOneWidget);
    expect(find.textContaining('One of 2 orientations of the 16 that land it.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('All ways round.'), findsNothing);
    expect(find.text('turns 0'), findsOneWidget);
  });

  testWidgets('show me names the street, and the pointer lands the green',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(find.textContaining('Turn the street between'), findsOneWidget);
    await pointAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, Levels.at(0).fewest);
    expect(find.textContaining('One of 78 orientations of the 4096 that land it.'),
        findsOneWidget);
  });

  testWidgets('the two rings land in four turns by the pointer', (tester) async {
    await open(tester, which: 3);
    await pointAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 4);
    expect(find.textContaining('One of 426 orientations'), findsOneWidget);
  });

  testWidgets('the toll lane admits it after three best tries', (tester) async {
    await open(tester, which: 4);
    await turnAll(tester, [6, 0, 1, 2, 3, 4, 5]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One way and no way back.'), findsOneWidget);
    expect(find.textContaining('No pointing of the toll lane works'),
        findsOneWidget);
    expect(find.textContaining('is the only way from one hamlet to the other'),
        findsOneWidget);
  });

  testWidgets('the why tells Robbins and the two counts', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Robbins\' theorem, from Herbert Robbins in 1939'),
        findsOneWidget);
    expect(find.textContaining('tried in full'), findsOneWidget);
  });
}
