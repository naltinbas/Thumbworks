import 'package:flutter_test/flutter_test.dart';
import 'package:trestlewick/raise/frames.dart';

import '../support/raise.dart';

void main() {
  testWidgets('a frame opens with nothing standing', (tester) async {
    await open(tester, which: 1);
    final play = state(tester).play;

    expect(play.day, 0);
    expect(play.standing, 0);
    expect(find.text(Frames.at(1).name), findsOneWidget);
    expect(find.textContaining('day 1, 0 of 3 crews set on'), findsOneWidget);
  });

  testWidgets('tapping a timber puts the crews on it', (tester) async {
    await open(tester, which: 1);
    await put(tester, 0);
    expect(state(tester).play.today, {0});
    await put(tester, 0);
    expect(state(tester).play.today, isEmpty);
  });

  testWidgets('a timber that is not ready says what it rests on',
      (tester) async {
    await open(tester, which: 1);
    await put(tester, 1);

    expect(state(tester).play.today, isEmpty);
    expect(find.textContaining('rests on Sill'), findsOneWidget);
  });

  testWidgets('and one already up says so', (tester) async {
    await open(tester, which: 1);
    await put(tester, 0);
    await press(tester, 'Raise the day');
    await put(tester, 0);
    expect(find.textContaining('is up already'), findsOneWidget);
  });

  testWidgets('there are only so many crews', (tester) async {
    await open(tester, which: 0);
    await put(tester, 0);
    await press(tester, 'Raise the day');
    await put(tester, 1);
    await put(tester, 2);
    expect(state(tester).play.today, hasLength(2));
    expect(find.textContaining('only 2 crews'), findsNothing);
  });

  testWidgets('raising the day with nobody set on says so', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Raise the day');
    expect(state(tester).play.day, 0);
    expect(find.textContaining('Put the crews on something'), findsOneWidget);
  });

  testWidgets('it says when a day has been wasted', (tester) async {
    // The queen post takes six days with four crews. Raising one timber a day
    // for the first two days throws one of them away.
    await open(tester, which: 3);
    await put(tester, 0);
    await press(tester, 'Raise the day');
    await put(tester, 1);
    await press(tester, 'Raise the day');

    expect(state(tester).play.couldFinishIn, greaterThan(6));
    expect(find.textContaining('The best this can be up in now is'),
        findsOneWidget);
  });

  testWidgets('Stand down clears the day and Again clears the site',
      (tester) async {
    await open(tester, which: 1);
    await put(tester, 0);
    await press(tester, 'Stand down');
    expect(state(tester).play.today, isEmpty);

    await put(tester, 0);
    await press(tester, 'Raise the day');
    await press(tester, 'Again');
    expect(state(tester).play.day, 0);
    expect(state(tester).play.standing, 0);
  });

  testWidgets('Show me puts the crews on and says how much is left',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');

    expect(state(tester).hints, 1);
    expect(state(tester).play.today, isNotEmpty);
    expect(find.textContaining('more days after this one'), findsOneWidget);
  });

  testWidgets('Why marks the run when the run is what holds it back',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');

    expect(state(tester).showRun, isTrue);
    expect(find.textContaining('each rest on the one before'), findsOneWidget);
  });

  testWidgets('and counts the work when the work is what holds it back',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');

    expect(state(tester).showRun, isFalse);
    expect(find.textContaining('days of work whatever order'), findsOneWidget);
  });

  testWidgets('every frame can be raised in the fewest days through the '
      'screen', (tester) async {
    // The proof that the game is playable: every frame raised by tapping
    // timbers, in as few days as it can be done in.
    for (var which = 0; which < Frames.count; which++) {
      final frame = Frames.at(which);
      await open(tester, which: which);
      await raiseItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: frame.name);
      expect(play.day, frame.days, reason: frame.name);
      expect(play.isFewest, isTrue, reason: frame.name);
      expect(find.bySemanticsLabel('the frame is standing'), findsOneWidget,
          reason: frame.name);
    }
  });
}
