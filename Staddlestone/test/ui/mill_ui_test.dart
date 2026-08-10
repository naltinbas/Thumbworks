import 'package:flutter_test/flutter_test.dart';
import 'package:staddlestone/mill/yards.dart';

import '../support/mill.dart';

void main() {
  testWidgets('a yard opens stacked on the first staddle', (tester) async {
    await open(tester, which: 1);
    final play = state(tester).play;

    expect(play.made, 0);
    expect(play.standing.on, [0, 0, 0]);
    expect(find.text(Yards.at(1).name), findsOneWidget);
  });

  testWidgets('a stone is lifted and set down', (tester) async {
    await open(tester, which: 1);
    await tapStaddle(tester, 0);
    expect(state(tester).play.lifted, 0);
    await tapStaddle(tester, 2);
    expect(state(tester).play.made, 1);
    expect(state(tester).play.topOf(2), 0);
  });

  testWidgets('tapping the same staddle puts the stone back', (tester) async {
    await open(tester, which: 1);
    await tapStaddle(tester, 0);
    await tapStaddle(tester, 0);
    expect(state(tester).play.lifted, -1);
    expect(state(tester).play.made, 0);
  });

  testWidgets('a bigger stone refuses to sit on a smaller, out loud',
      (tester) async {
    await open(tester, which: 1);
    await move(tester, 0, 2);
    await tapStaddle(tester, 0);
    await tapStaddle(tester, 2);

    expect(state(tester).play.made, 1);
    expect(find.textContaining('never sits on a smaller'), findsOneWidget);
  });

  testWidgets('a bare staddle says so', (tester) async {
    await open(tester, which: 1);
    await tapStaddle(tester, 1);
    expect(find.textContaining('bare'), findsOneWidget);
  });

  testWidgets('the big stone crossing is called out with the count',
      (tester) async {
    await open(tester, which: 1);
    // The seven move way: s to 2, m to 1, s to 1, b to 2 is the crossing.
    await move(tester, 0, 2);
    await move(tester, 0, 1);
    await move(tester, 2, 1);
    await move(tester, 0, 2);

    expect(state(tester).play.biggestHome, isTrue);
    expect(find.textContaining('The big stone is home on move 4'),
        findsOneWidget);
  });

  testWidgets('a wasted move is called out at once', (tester) async {
    await open(tester, which: 1);
    await move(tester, 0, 1);
    expect(find.textContaining('more than the 7 it takes'), findsOneWidget);
  });

  testWidgets('Again restacks the yard', (tester) async {
    await open(tester, which: 1);
    await move(tester, 0, 2);
    await press(tester, 'Again');
    expect(state(tester).play.made, 0);
  });

  testWidgets('Show me lifts nothing but points true', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing, isNonNegative);
    expect(find.textContaining('more after this one'), findsOneWidget);
  });

  testWidgets('Why tells the doubling', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(find.textContaining('Twice 3 and one is 7'), findsOneWidget);
  });

  testWidgets('every yard can be worked at par through the screen',
      (tester) async {
    // The proof that the game is playable: every yard worked by tapping
    // staddles, in as few moves as there are.
    for (var which = 0; which < Yards.count; which++) {
      final yard = Yards.at(which);
      await open(tester, which: which);
      await workItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: yard.name);
      expect(play.made, yard.fewest, reason: yard.name);
      expect(play.isFewest, isTrue, reason: yard.name);
      expect(find.bySemanticsLabel('the stack is home'), findsOneWidget,
          reason: yard.name);
    }
  });
}
