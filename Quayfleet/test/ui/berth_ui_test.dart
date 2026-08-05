import 'package:flutter_test/flutter_test.dart';
import 'package:quayfleet/berth/quays.dart';

import '../support/berth.dart';

void main() {
  testWidgets('a day opens with an empty berth', (tester) async {
    await open(tester, which: 2);
    final play = state(tester).play;

    expect(play.taken, isEmpty);
    expect(play.isDone, isFalse);
    expect(find.text(Days.at(2).name), findsOneWidget);
    expect(find.textContaining('7 of 7 still waiting'), findsOneWidget);
  });

  testWidgets('tapping a ship gives her the berth', (tester) async {
    await open(tester, which: 2);
    await berth(tester, 5);

    expect(state(tester).play.has(5), isTrue);
    expect(state(tester).play.taken, [5]);
  });

  testWidgets('and tapping her again takes it back', (tester) async {
    await open(tester, which: 2);
    await berth(tester, 5);
    await berth(tester, 5);
    expect(state(tester).play.taken, isEmpty);
  });

  testWidgets('a ship that clashes says who has the berth', (tester) async {
    await open(tester, which: 1);
    await berth(tester, 0);
    await berth(tester, 1);

    expect(state(tester).play.has(1), isFalse);
    expect(find.textContaining('has it until'), findsOneWidget);
    expect(state(tester).pointing, 0);
  });

  testWidgets('it says when the day can no longer be as good', (tester) async {
    // The Providence holds the berth from six to twelve on the second day,
    // and two ships are turned away for her.
    await open(tester, which: 1);
    await berth(tester, 0);

    expect(state(tester).play.couldStillGet, 2);
    expect(find.textContaining('The best this day can come to now is 2'),
        findsOneWidget);
  });

  testWidgets('Again empties the berth', (tester) async {
    await open(tester, which: 2);
    await berth(tester, 5);
    await press(tester, 'Again');
    expect(state(tester).play.taken, isEmpty);
  });

  testWidgets('Show me points at a ship that keeps the day whole',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing, isNonNegative);
    expect(find.textContaining('She casts off before anything else'),
        findsOneWidget);

    await berth(tester, screen.pointing);
    expect(state(tester).play.couldStillGet, state(tester).play.most);
  });

  testWidgets('Why draws the hours that settle the day', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');

    expect(state(tester).showMarks, isTrue);
    expect(find.textContaining('wants the berth at'), findsOneWidget);
    expect(find.textContaining('3 is all there is'), findsOneWidget);
  });

  testWidgets('a day can be worked badly, and it says so at the end',
      (tester) async {
    await open(tester, which: 1);
    // The Providence first, which is the wrong ship and costs the day: she
    // holds the berth until noon and only the Bess of Wells is left after
    // her.
    await berth(tester, 0);
    await berth(tester, 4);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.isMost, isFalse);
    expect(find.textContaining('It would have taken 3'), findsOneWidget);
  });

  testWidgets('every day can be worked up to the most through the screen',
      (tester) async {
    // The proof that the game is playable: every day worked by tapping ships,
    // and every one of them up to the most the berth will take.
    for (var which = 0; which < Days.count; which++) {
      final day = Days.at(which);
      await open(tester, which: which);
      await workItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: day.name);
      expect(play.isMost, isTrue, reason: day.name);
      expect(play.taken, hasLength(day.most), reason: day.name);
      expect(find.bySemanticsLabel('the day is over'), findsOneWidget,
          reason: day.name);
    }
  });
}
