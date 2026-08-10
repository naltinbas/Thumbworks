import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treblesway/best.dart';
import 'package:treblesway/ring/peals.dart';

import '../support/ring.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many towers there are and how many ring',
      (tester) async {
    await open(tester);
    expect(find.text('5 towers, 4 of them ringable'), findsOne);
  });

  testWidgets('labels the split tower on the list', (tester) async {
    await open(tester);
    expect(find.textContaining('cannot ring the 24'), findsOneWidget);
  });

  testWidgets('and how many have been rung', (tester) async {
    await open(tester, best: await keeper({'rung.$_first': 0}));
    expect(find.text('1 of 4 rung'), findsOne);
  });

  testWidgets('tapping a tower opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.peal.name, _first);
  });

  testWidgets('writes a peal down when rounds strikes home', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await ringItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    // The helper reads the way ahead without ever pressing Show me, so the
    // peal is recorded with no askings at all.
    expect(best.hintsFor(Peals.at(0).name), 0);
  });

  testWidgets('and a peal left part rung writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await ring(tester, 'cross');

    expect(best.done, 0);
  });
}

String get _first => Peals.at(0).name;
