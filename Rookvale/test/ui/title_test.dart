import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rookvale/best.dart';
import 'package:rookvale/board/puzzles.dart';
import 'package:rookvale/board/solve.dart';

import '../support/board.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many puzzles there are', (tester) async {
    await open(tester);
    expect(find.text('${Puzzles.count} puzzles'), findsOne);
  });

  testWidgets('and how many have been done', (tester) async {
    await open(tester, best: await keeper({'done.Corner work': 2}));
    expect(find.text('1 of ${Puzzles.count} done'), findsOne);
  });

  testWidgets('writes down a puzzle, once it is actually finished',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await solveIt(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.has('Corner work'), isTrue);
    expect(best.isClean('Corner work'), isTrue,
        reason: 'nothing was asked for and nothing was taken back');
  });

  testWidgets('but not as found when the game was asked', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await press(tester, 'Show me');
    for (final move in waysThrough(Puzzles.at(0).board).first) {
      await capture(tester, move.from, move.to);
    }
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.has('Corner work'), isTrue);
    expect(best.isClean('Corner work'), isFalse);
  });

  testWidgets('and a puzzle left half done writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    final first = waysThrough(Puzzles.at(0).board).first.first;
    await capture(tester, first.from, first.to);
    await tester.pump();

    expect(best.done, 0);
  });
}
