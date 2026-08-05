import 'package:flutter_test/flutter_test.dart';
import 'package:winnowmere/sift/puzzles.dart';

import '../support/sift.dart';

void main() {
  testWidgets('a puzzle opens with what it gives and nothing else',
      (tester) async {
    await open(tester, which: 3);
    final play = state(tester).play;

    expect(play.count, Siftings.at(3).given.length);
    expect(play.isDone, isFalse);
    expect(find.text(Siftings.at(3).name), findsOneWidget);
    expect(find.textContaining('of ${play.rows} rows sorted'), findsOneWidget);
  });

  testWidgets('tapping two lines puts a comparator between them',
      (tester) async {
    await open(tester, which: 2);
    await touch(tester, 0);
    expect(state(tester).holding, 0);

    await touch(tester, 1);
    expect(state(tester).play.count, 1);
    expect(state(tester).play.sieve.crosses.last.upper, 0);
    expect(state(tester).play.sieve.crosses.last.lower, 1);
    expect(state(tester).holding, -1);
  });

  testWidgets('and tapping the same line twice lets go of it', (tester) async {
    await open(tester, which: 2);
    await touch(tester, 1);
    await touch(tester, 1);
    expect(state(tester).holding, -1);
    expect(state(tester).play.count, 0);
  });

  testWidgets('the game names a row that still comes out wrong',
      (tester) async {
    await open(tester, which: 2);
    await put(tester, 0, 1);

    final play = state(tester).play;
    expect(play.fails, isNotNull);
    expect(state(tester).showing, play.fails);
    expect(find.textContaining('comes out'), findsOneWidget);
    expect(find.textContaining('rows are right'), findsOneWidget);
  });

  testWidgets('tapping a comparator takes it out', (tester) async {
    await open(tester, which: 2);
    await put(tester, 0, 1);
    await put(tester, 2, 3);
    expect(state(tester).play.count, 2);

    await takeOut(tester, 1);
    expect(state(tester).play.count, 1);
  });

  testWidgets('and one the puzzle gave stays put', (tester) async {
    await open(tester, which: 3);
    final was = state(tester).play.count;

    await takeOut(tester, 0);
    expect(state(tester).play.count, was);
    expect(find.textContaining('came with the puzzle'), findsOneWidget);
  });

  testWidgets('Again puts it back to what it started with', (tester) async {
    await open(tester, which: 3);
    await put(tester, 1, 2);
    await press(tester, 'Again');

    expect(state(tester).play.count, Siftings.at(3).given.length);
    expect(state(tester).play.changes, 0);
  });

  testWidgets('Show me puts the next comparator of an answer in',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');

    expect(state(tester).play.count, 1);
    expect(state(tester).hints, 1);
    expect(find.textContaining('more after that'), findsOneWidget);
  });

  testWidgets('every puzzle can be finished through the screen, in par',
      (tester) async {
    // The proof that the game is playable: each network built two taps at a
    // time, sorting every row there is, in the fewest comparators there are.
    for (var which = 0; which < Siftings.count; which++) {
      await open(tester, which: which);
      await sortItAll(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: Siftings.at(which).name);
      expect(play.isTight, isTrue, reason: Siftings.at(which).name);
      expect(play.right, play.rows, reason: Siftings.at(which).name);
      expect(find.bySemanticsLabel('it sorts'), findsOneWidget,
          reason: Siftings.at(which).name);
    }
  });
}
