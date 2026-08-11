import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:withyshaw/best.dart';
import 'package:withyshaw/hedge/hedges.dart';

import '../support/hedge.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and its rule', (tester) async {
    await open(tester);
    expect(find.text('Withyshaw'), findsOne);
    expect(
      find.text('Cut your withies, never theirs. Whoever cannot cut has '
          'lost the hedge.'),
      findsOne,
    );
  });

  testWidgets('lists every hedge with its worth, and labels the nought',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('1 stalk, worth 1/2'), findsOne);
    expect(find.textContaining('whoever cuts first loses, and that is '
        'you'), findsOne);
  });

  testWidgets('shows a hedge held clean', (tester) async {
    await open(tester, best: await keeper({'hedged.$_first': 0}));
    expect(find.text('held unasked'), findsOne);
  });

  testWidgets('tapping a hedge opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.hedge.name, _first);
  });

  testWidgets('writes a held hedge down with its askings', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await holdItAll(tester);
    await tester.pump();

    expect(best.askingsFor(_first), 0);
  });

  testWidgets('a hedge left standing writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    final next = state(tester).play.next!;
    await cut(tester, next.$1, next.$2);

    expect(best.done, 0);
  });
}

String get _first => Hedges.at(0).name;
