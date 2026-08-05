import 'package:flutter_test/flutter_test.dart';
import 'package:weirbank/flow/works_list.dart';

import '../support/flow.dart';

void main() {
  testWidgets('a works opens with every pipe empty', (tester) async {
    await open(tester, which: 2);
    final play = state(tester).play;

    expect(play.down.every((down) => down == 0), isTrue);
    expect(play.arriving, 0);
    expect(find.text(Waterworks.at(2).name), findsOneWidget);
    expect(find.textContaining('of ${Waterworks.at(2).target} at the mill'),
        findsOneWidget);
  });

  testWidgets('tapping a pipe sends one more down it', (tester) async {
    await open(tester, which: 2);
    await turn(tester, 0);
    expect(state(tester).play.downPipe(0), 1);

    await turn(tester, 0);
    expect(state(tester).play.downPipe(0), 2);
  });

  testWidgets('and past full it comes round to nothing', (tester) async {
    await open(tester, which: 2);
    final holds = state(tester).play.works.pipes[0].holds;
    for (var one = 0; one < holds; one++) {
      await turn(tester, 0);
    }
    expect(state(tester).play.downPipe(0), holds);

    await turn(tester, 0);
    expect(state(tester).play.downPipe(0), 0);
  });

  testWidgets('a pond that does not add up says so, by name', (tester) async {
    await open(tester, which: 2);
    await turn(tester, 0);

    expect(state(tester).play.spills, hasLength(1));
    expect(find.textContaining('more arrives at the'), findsOneWidget);
    expect(find.textContaining('do not add up'), findsNothing,
        reason: 'one pond is "does not"');
  });

  testWidgets('Again empties the works', (tester) async {
    await open(tester, which: 2);
    await turn(tester, 0);
    await turn(tester, 1);
    await press(tester, 'Again');

    expect(state(tester).play.down.every((down) => down == 0), isTrue);
    expect(state(tester).play.turns, 0);
  });

  testWidgets('Show me points at a pipe and says what it should carry',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.pointing, isNonNegative);
    expect(screen.hints, 1);
    expect(find.textContaining('in the answer'), findsOneWidget);
  });

  testWidgets('Why no more shows the cut and what it holds', (tester) async {
    // The thing this game is for. It is not an excuse, it is the reason:
    // those pipes hold exactly what the mill is being asked for.
    await open(tester, which: 2);
    await press(tester, 'Why no more');

    final screen = state(tester);
    expect(screen.showCut, isTrue);
    expect(screen.most.cut, isNotEmpty);
    expect(screen.most.holdsOfCut(screen.play.works), screen.waterwork.target);
    expect(find.textContaining('hold the whole works back'), findsOneWidget);
    expect(find.textContaining('all there is'), findsOneWidget);
  });

  testWidgets('every works can be set through the screen', (tester) async {
    // The proof that the game is playable: every works set to the most it
    // will carry by the same taps a finger makes.
    for (var which = 0; which < Waterworks.count; which++) {
      await open(tester, which: which);
      await setItAll(tester);

      final play = state(tester).play;
      expect(play.holds, isTrue, reason: Waterworks.at(which).name);
      expect(play.arriving, Waterworks.at(which).target,
          reason: Waterworks.at(which).name);
      expect(play.isDone, isTrue, reason: Waterworks.at(which).name);
      expect(find.bySemanticsLabel('the mill has its water'), findsOneWidget,
          reason: Waterworks.at(which).name);
    }
  });
}
