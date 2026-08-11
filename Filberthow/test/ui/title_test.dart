import 'package:filberthow/best.dart';
import 'package:filberthow/hoard/hoards.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/hoard.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and its rule', (tester) async {
    await open(tester);
    expect(find.text('Filberthow'), findsOne);
    expect(
      find.text('Take up to twice the last take. The last hazelnut wins '
          'the hoard.'),
      findsOne,
    );
  });

  testWidgets('lists every hoard with its split', (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('20 nuts: 13 + 5 + 2'), findsOne);
    expect(find.textContaining('one whole cluster'), findsOne);
  });

  testWidgets('shows a hoard won clean', (tester) async {
    await open(tester, best: await keeper({'hoarded.$_first': 0}));
    expect(find.text('won unasked'), findsOne);
  });

  testWidgets('tapping a hoard opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.hoard.name, _first);
  });

  testWidgets('writes a won hoard down with its askings', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await winItAll(tester);
    await tester.pump();

    expect(best.askingsFor(_first), greaterThan(0));
  });

  testWidgets('a hoard left standing writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await take(tester, 2);

    expect(best.done, 0);
  });
}

String get _first => Hoards.at(0).name;
