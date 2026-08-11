import 'package:flutter_test/flutter_test.dart';
import 'package:millgreave/best.dart';
import 'package:millgreave/moor/moors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/moor.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Millgreave'), findsOne);
    expect(
      find.text('Raise a mill in every file, and let no two share the '
          'wind.'),
      findsOne,
    );
  });

  testWidgets('lists every moor, and labels the impossible one',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('4 plots a side, 2 settings'), findsOne);
    expect(find.textContaining('the why walks the cases'), findsOne);
  });

  testWidgets('shows a moor set clean', (tester) async {
    await open(tester, best: await keeper({'milled.$_first': 0}));
    expect(find.text('set unasked'), findsOne);
  });

  testWidgets('tapping a moor opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.moor.name, _first);
  });

  testWidgets('writes a set moor down with its askings', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await setItAll(tester);
    await tester.pump();

    expect(best.askingsFor(_first), 0);
  });

  testWidgets('a moor left part set writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await raise(tester, 0, 1);

    expect(best.done, 0);
  });
}

String get _first => Moors.at(0).name;
