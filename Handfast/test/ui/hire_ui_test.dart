import 'package:flutter_test/flutter_test.dart';
import 'package:handfast/hire/fairs.dart';

import '../support/hire.dart';

void main() {
  testWidgets('a day opens with nothing given out', (tester) async {
    await open(tester, which: 3);
    final play = state(tester).play;

    expect(play.covered, 0);
    expect(play.isDone, isFalse);
    expect(find.text(Days.at(3).name), findsOneWidget);
    expect(find.textContaining('7 of 7 still to give out'), findsOneWidget);
  });

  testWidgets('tapping a cross gives that job to that hand', (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 0, 1);

    expect(state(tester).play.handOn(0), 1);
    expect(state(tester).play.covered, 1);
  });

  testWidgets('and tapping it again takes it back', (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 0, 1);
    await tapCell(tester, 0, 1);
    expect(state(tester).play.covered, 0);
  });

  testWidgets('tapping the job down the side takes it back too',
      (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 0, 1);
    await tapJob(tester, 0);
    expect(state(tester).play.covered, 0);
  });

  testWidgets('a hand who cannot do the job says so', (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 0, 0);

    expect(state(tester).play.covered, 0);
    expect(find.textContaining('does not do'), findsOneWidget);
  });

  testWidgets('and one already taken on says what they are on', (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 0, 3);
    await tapCell(tester, 1, 3);

    expect(state(tester).play.covered, 1);
    expect(find.textContaining('is already on'), findsOneWidget);
    expect(state(tester).pointing, (0, 3));
  });

  testWidgets('it says when the day can no longer cover as much',
      (tester) async {
    // Ditching and Carting can both only be done by Wray, so taking Wray for
    // Hedging strands one of them.
    await open(tester, which: 0);
    await tapCell(tester, 0, 3);

    expect(state(tester).play.couldStillGet, lessThan(6));
    expect(find.textContaining('The best this day can come to now is'),
        findsOneWidget);
  });

  testWidgets('Again clears the board', (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 0, 1);
    await press(tester, 'Again');
    expect(state(tester).play.covered, 0);
  });

  testWidgets('Show me points at a job and a hand', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.hints, 1);
    expect(screen.pointing.$1, isNonNegative);
    expect(screen.pointing.$2, isNonNegative);

    await tapCell(tester, screen.pointing.$1, screen.pointing.$2);
    expect(state(tester).play.couldStillGet, state(tester).play.most);
  });

  testWidgets('Why names the jobs with too few hands', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');

    expect(state(tester).showShort, isTrue);
    expect(find.textContaining('can only be taken on by'), findsOneWidget);
    expect(find.textContaining('goes undone whatever anybody does'),
        findsOneWidget);
  });

  testWidgets('and on a board that can all be covered it says that',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(find.textContaining('at least as many hands'), findsOneWidget);
  });

  testWidgets('a day can be given out badly, and it says so at the end',
      (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 0, 3);
    await giveItAll(tester);

    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.isMost, isFalse);
    expect(find.textContaining('could have been'), findsOneWidget);
  });

  testWidgets('every day can be covered up to the most through the screen',
      (tester) async {
    // The proof that the game is playable: every board given out by tapping
    // crosses, and every one of them up to the most that can be covered.
    for (var which = 0; which < Days.count; which++) {
      final day = Days.at(which);
      await open(tester, which: which);
      await giveItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: day.name);
      expect(play.isMost, isTrue, reason: day.name);
      expect(play.covered, day.most, reason: day.name);
      expect(find.bySemanticsLabel('the work is given out'), findsOneWidget,
          reason: day.name);
    }
  });
}
