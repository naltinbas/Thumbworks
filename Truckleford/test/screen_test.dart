import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truckleford/yard/rules.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// One ask on the screen, the yard worked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('send the wagons out with wagon 1 last'),
        findsOneWidget);
    expect(find.text('siding empty'), findsOneWidget);
    expect(find.text('out none'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Nothing has gone out yet.'), findsOneWidget);
  });

  testWidgets('the three levers move the wagons about', (tester) async {
    // Worked on the hopeless ask, where a run is never cut short for
    // going the wrong way about it.
    await open(tester, which: 4);
    await work(tester, Rules.shunt);
    expect(state(tester).play.siding, [1]);
    expect(find.text('siding 1'), findsOneWidget);
    await work(tester, Rules.roll);
    expect(find.text('out 2'), findsOneWidget);
    await work(tester, Rules.send);
    expect(find.text('out 2, 1'), findsOneWidget);
    expect(find.text('The out-train reads 2, 1.'), findsOneWidget);
    await press(tester, 'Back');
    expect(find.text('out 2'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
  });

  testWidgets('send does nothing with the siding empty', (tester) async {
    await open(tester, which: 1);
    expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key(Rules.send)))
            .onPressed,
        isNull);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('nothing moved lands in six rolls and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await run(tester, List.filled(6, Rules.roll));
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Away.'), findsOneWidget);
    expect(find.text('As asked. The out-train reads 1, 2, 3, 4, 5, 6.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'The out-train reads 1, 2, 3, 4, 5, 6, and the siding made it: '
            'one of 1 out-train of the 132 that lands the ask, out of the 720 '
            'orders six wagons can stand in; 6 taps.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Away.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the lever, and the pointer lands the reversal',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Shunt the wagon at the head onto the siding.'),
        findsOneWidget);
    expect(state(tester).pointing, Rules.shunt);
    await runByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.out, [6, 5, 4, 3, 2, 1]);
    expect(state(tester).play.moves, 11);
    expect(
        find.textContaining('one of 1 out-train of the 132 that lands the '
            'ask, out of the 720 orders six wagons can stand in; 11 taps.'),
        findsOneWidget);
  });

  testWidgets('a run that cannot land the ask says it is wedged',
      (tester) async {
    await open(tester, which: 3);
    await work(tester, Rules.roll);
    expect(state(tester).play.wedged, isTrue);
    expect(find.text('Wedged.'), findsOneWidget);
    expect(find.text('Nothing left to do here will land the ask.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'Only the wagon at the points can be sent, so anything behind it '
            'has to follow it out.'),
        findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.wedged, isFalse);
    expect(find.text('Wedged.'), findsNothing);
  });

  testWidgets('wagon one last takes a shunt, five rolls and a send',
      (tester) async {
    await open(tester, which: 1);
    await run(tester, [
      Rules.shunt,
      Rules.roll,
      Rules.roll,
      Rules.roll,
      Rules.roll,
      Rules.roll,
      Rules.send,
    ]);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.out, [2, 3, 4, 5, 6, 1]);
    expect(
        find.textContaining('one of 42 out-trains of the 132 that land the '
            'ask'),
        findsOneWidget);
  });

  testWidgets('three, one, two gives itself up at the points', (tester) async {
    await open(tester, which: 4);
    await run(tester, [Rules.shunt, Rules.shunt, Rules.shunt, Rules.send]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The points say no.'), findsOneWidget);
    expect(
        find.text('Wagon 2 sits at the points with wagon 1 behind it, and '
            'only the wagon at the points can be sent.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'Getting 3 out first means shunting 1 and 2 onto the siding, 1 '
            'first and 2 behind it, which leaves 2 at the points'),
        findsOneWidget);
  });

  testWidgets('the why tells Knuth and the shape', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Donald Knuth set this down in 1968'),
        findsOneWidget);
    expect(
        find.textContaining(
            'the counts for one wagon up to eight are 1, 2, 5, 14, 42, 132, '
            '429, 1430, the Catalan numbers'),
        findsOneWidget);
  });
}
