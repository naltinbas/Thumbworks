import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnstead/best.dart';
import 'package:turnstead/green/greens.dart';

import '../support/green.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and its card', (tester) async {
    await open(tester);
    expect(find.text('Turnstead'), findsOne);
    expect(
      find.text('Write the fixture card: every side plays every side '
          'exactly once.'),
      findsOne,
    );
  });

  testWidgets('lists every green, and labels the short card',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('4 sides, 3 rounds, 6 matches'), findsOne);
    expect(find.textContaining('one breath says why'), findsOne);
  });

  testWidgets('shows a card written clean', (tester) async {
    await open(tester, best: await keeper({'fixtured.$_first': 0}));
    expect(find.text('written unasked'), findsOne);
  });

  testWidgets('tapping a green opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.green.name, _first);
  });

  testWidgets('writes a written card down with its askings',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await writeItAll(tester);
    await tester.pump();

    expect(best.askingsFor(_first), 0);
  });

  testWidgets('a card left part written writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await pair(tester, 0, 2);

    expect(best.done, 0);
  });
}

String get _first => Greens.at(0).name;
