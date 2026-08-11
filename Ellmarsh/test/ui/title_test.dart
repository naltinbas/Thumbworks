import 'package:ellmarsh/best.dart';
import 'package:ellmarsh/cloth/benches.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/cloth.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and its rule', (tester) async {
    await open(tester);
    expect(find.text('Ellmarsh'), findsOne);
    expect(
      find.text('Cut lengths of the short bolt from the long one. The '
          'last cut keeps the bench.'),
      findsOne,
    );
  });

  testWidgets('lists every bench, and labels the golden one',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('25 and 7 ells'), findsOne);
    expect(find.textContaining('inside the gap: the mercer holds it'),
        findsOne);
  });

  testWidgets('shows a bench held clean', (tester) async {
    await open(tester, best: await keeper({'held.$_first': 0}));
    expect(find.text('held unasked'), findsOne);
  });

  testWidgets('tapping a bench opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.bench.name, _first);
  });

  testWidgets('writes a held bench down with its askings', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await holdItAll(tester);
    await tester.pump();

    expect(best.askingsFor(_first), greaterThan(0));
  });

  testWidgets('a bench left standing writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await cut(tester, 2);

    expect(best.done, 0);
  });
}

String get _first => Benches.at(0).name;
