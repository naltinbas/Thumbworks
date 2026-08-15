import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// One reach on the screen, leapt as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a reach opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(
      find.textContaining('leap a frog to the third reach with 8 frogs'),
      findsOneWidget,
    );
    expect(find.text('frogs 8'), findsOneWidget);
    expect(find.text('leaps 0'), findsOneWidget);
    expect(find.text('weight 1.000'), findsOneWidget);
    expect(
      find.text('Frogs 8, weight 1.000 against the aim\'s one.'),
      findsOneWidget,
    );
  });

  testWidgets('a pick shows, and a leap counts', (tester) async {
    await open(tester, which: 1);
    await tapPad(tester, (0, -1));
    expect(state(tester).play.picked, (0, -1));
    expect(
      find.textContaining('Frog picked; tap an empty pad two along'),
      findsOneWidget,
    );
    await tapPad(tester, (0, 1));
    expect(state(tester).play.frogs, contains((0, 1)));
    expect(find.text('frogs 3'), findsOneWidget);
    expect(find.text('leaps 1'), findsOneWidget);
    expect(find.text('weight 1.000'), findsOneWidget);
    await press(tester, 'Back');
    expect(find.text('frogs 4'), findsOneWidget);
    expect(find.text('leaps 0'), findsOneWidget);
  });

  testWidgets('a wasted leap turns the weight rust and warns',
      (tester) async {
    await open(tester, which: 1);
    await leap(tester, (0, 0), (0, -2));
    expect(find.text('weight 0.528'), findsOneWidget);
    expect(
      find.text('No road lands from here: take a leap back.'),
      findsOneWidget,
    );
  });

  testWidgets('the second reach lands by hand and shows the card',
      (tester) async {
    await open(tester, which: 1);
    await leap(tester, (0, -1), (0, 1));
    await leap(tester, (2, 0), (0, 0));
    await leap(tester, (0, 0), (0, 2));
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Reached.'), findsOneWidget);
    expect(
      find.textContaining('A frog on the aim; 3 leaps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Reached.'), findsNothing);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('show me rings a leap', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.text('Leap the ringed frog into the ringed pad.'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer leaps the fourth reach in nineteen',
      (tester) async {
    await open(tester, which: 3);
    await leapByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 19);
  });

  testWidgets('the hopeless reach cracks at twelve leaps',
      (tester) async {
    await open(tester, which: 4);
    const leaps = [
      ((4, -1), (4, -3)),
      ((2, -2), (4, -2)), ((2, -1), (4, -1)),
      ((0, -2), (2, -2)), ((0, -1), (2, -1)),
      ((-2, -2), (0, -2)), ((-2, -1), (0, -1)),
      ((-4, -2), (-2, -2)), ((-4, -1), (-2, -1)),
      ((2, -1), (2, -3)), ((0, -1), (0, -3)), ((-2, -1), (-2, -3)),
    ];
    for (final (from, to) in leaps) {
      await leap(tester, from, to);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The fifth reach is never reached.'), findsOneWidget);
    expect(
      find.textContaining('the whole pond weighs one against it'),
      findsOneWidget,
    );
  });

  testWidgets('the why weighs the pond', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('weighs exactly one against the fifth reach'),
      findsOneWidget,
    );
    expect(
      find.textContaining('twenty-seven frogs weigh 0.679'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the fourth reach counts the orders',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('369106018 roads land'),
      findsOneWidget,
    );
    expect(
      find.textContaining('every one of the 84 such armies'),
      findsOneWidget,
    );
  });
}
