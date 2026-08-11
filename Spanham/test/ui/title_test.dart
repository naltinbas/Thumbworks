import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spanham/best.dart';
import 'package:spanham/row/levels.dart';

import '../support/row.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Spanham'), findsOne);
    expect(
      find.text('Set the paired blocks so each pair holds its own number '
          'of seats between.'),
      findsOne,
    );
  });

  testWidgets('lists every shelf, and labels the impossible one',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('3 pairs, 2 settings'), findsOne);
    expect(find.textContaining('the why is arithmetic'), findsOne);
  });

  testWidgets('shows a shelf set clean', (tester) async {
    await open(tester, best: await keeper({'set.$_first': 0}));
    expect(find.text('set unasked'), findsOne);
  });

  testWidgets('tapping a shelf opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.level.name, _first);
  });

  testWidgets('writes a set shelf down with its askings', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await setItAll(tester);
    await tester.pump();

    expect(best.askingsFor(_first), 0);
  });

  testWidgets('a shelf left part set writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await place(tester, 0);

    expect(best.done, 0);
  });
}

String get _first => Levels.at(0).name;
