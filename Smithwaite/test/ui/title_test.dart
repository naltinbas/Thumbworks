import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smithwaite/best.dart';
import 'package:smithwaite/forge/puzzles.dart';

import '../support/forge.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Smithwaite'), findsOne);
    expect(
      find.text('Work the rings off the smith\'s bar in the fewest moves '
          'there are.'),
      findsOne,
    );
  });

  testWidgets('lists every puzzle, the tangle with its one ring on',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('3 rings, fewest 5'), findsOne);
    expect(find.text('5 rings, one on, fewest 31'), findsOne);
  });

  testWidgets('shows what a puzzle has been freed on', (tester) async {
    await open(tester, best: await keeper({'freed.$_first': 5}));
    expect(find.text('freed on 5'), findsOne);
  });

  testWidgets('tapping a puzzle opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.puzzle.name, _first);
  });

  testWidgets('writes a freeing down when the bar slides out', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await freeItAll(tester);
    await tester.pump();

    expect(best.movesFor(_first), Puzzles.at(0).fewest);
  });

  testWidgets('a puzzle left part worked writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await move(tester, 0);

    expect(best.done, 0);
  });
}

String get _first => Puzzles.at(0).name;
