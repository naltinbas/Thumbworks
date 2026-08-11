import 'package:flutter_test/flutter_test.dart';
import 'package:posygarth/best.dart';
import 'package:posygarth/garden/garths.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/garth.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and its law', (tester) async {
    await open(tester);
    expect(find.text('Posygarth'), findsOne);
    expect(
      find.text('Each line takes each flower once and each colour once, '
          'and no pairing repeats.'),
      findsOne,
    );
  });

  testWidgets('lists every garth, and labels the impossible one',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('3 beds a side'), findsOne);
    expect(find.textContaining('the sweep is watchable'), findsOne);
    expect(find.textContaining('the top row seeded'), findsOne);
  });

  testWidgets('shows a garth bloomed clean', (tester) async {
    await open(tester, best: await keeper({'bloomed.$_first': 0}));
    expect(find.text('bloomed unasked'), findsOne);
  });

  testWidgets('tapping a garth opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.garth.name, _first);
  });

  testWidgets('writes a bloomed garth down with its askings',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await bloomItAll(tester);
    await tester.pump();

    expect(best.askingsFor(_first), isNotNull);
  });

  testWidgets('a garth left part planted writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await plant(tester, 0, 1, 2);

    expect(best.done, 0);
  });
}

String get _first => Garths.at(0).name;
