import 'package:flutter_test/flutter_test.dart';
import 'package:foldbury/best.dart';
import 'package:foldbury/fold/folds.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fold.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Foldbury'), findsOne);
    expect(
      find.text('Post the fewest shepherds that leave no lane unwatched.'),
      findsOne,
    );
  });

  testWidgets('lists every fold with its size and its number', (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('5 gates, 4 lanes, 2 shepherds'), findsOne);
    expect(find.text('The Three Lanes'), findsOne);
  });

  testWidgets('shows what a fold has been watched on', (tester) async {
    await open(tester, best: await keeper({'watched.$_first': 2}));
    expect(find.text('watched on 2'), findsOne);
  });

  testWidgets('tapping a fold opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.fold.name, _first);
  });

  testWidgets('writes a night down when the last lane is watched',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await watchItAll(tester);
    await tester.pump();

    expect(best.shepherdsFor(_first), Folds.at(0).fewest);
  });

  testWidgets('and a worse night never writes over a better one',
      (tester) async {
    final best = await keeper({'watched.$_first': 2});
    await open(tester, which: 0, best: best);

    // Post every gate: watched on five.
    for (var gate = 0; gate < Folds.at(0).count; gate++) {
      await post(tester, gate);
    }
    await tester.pump();

    expect(best.shepherdsFor(_first), 2);
  });

  testWidgets('a night left part watched writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await post(tester, 1);

    expect(best.done, 0);
  });
}

String get _first => Folds.at(0).name;
