import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/laneland.dart';

/// One ask on the screen, the pump rolled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens with the pump at the near end', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('stand the pump where the walking comes to 15'),
        findsOneWidget);
    expect(find.text('walking 30'), findsOneWidget);
    expect(find.text('steps 0'), findsOneWidget);
    expect(find.textContaining('The pump at spot 0, and the walking comes to 30.'),
        findsOneWidget);
  });

  testWidgets('a tap rolls the pump one spot that way', (tester) async {
    await open(tester, which: 0);
    await tapSpot(tester, 9);
    expect(state(tester).play.spot, 1);
    expect(find.text('steps 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.spot, 0);
  });

  testWidgets('the five houses land at the middle one', (tester) async {
    await open(tester, which: 0);
    await rollTo(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Least walking.'), findsOneWidget);
    expect(
        find.textContaining('The pump at spot 5 and the walking at 15, which is the least there is.'),
        findsOneWidget);
    expect(find.textContaining('The average falls at spot 6, where the walking comes to 16.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Least walking.'), findsNothing);
  });

  testWidgets('the six houses take any spot of the run', (tester) async {
    await open(tester, which: 1);
    await rollTo(tester, 4);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 4);
    expect(find.textContaining('anywhere from spot 4 to 8'), findsOneWidget);
    expect(find.textContaining('5 of the 13 spots land it'), findsOneWidget);
  });

  testWidgets('show me rolls the pump the right way', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Roll the pump one spot up the lane.'), findsOneWidget);
    await rollAllByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.spot, 9);
    expect(state(tester).play.moves, 9);
  });

  testWidgets('beat the middle admits it at the middle', (tester) async {
    await open(tester, which: 4);
    await rollTo(tester, 5);
    expect(state(tester).play.walk, 15);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The middle has it.'), findsOneWidget);
    expect(find.textContaining('Nothing on the lane walks less than 15'),
        findsOneWidget);
  });

  testWidgets('the why tells the middle and the average', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('the houses behind less the houses ahead'),
        findsOneWidget);
    expect(find.textContaining('walked in full before the sham'), findsOneWidget);
  });
}
