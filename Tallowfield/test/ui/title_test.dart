import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallowfield/best.dart';
import 'package:tallowfield/garden/evenings.dart';

import '../support/garden.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Tallowfield'), findsOne);
    expect(
      find.text('Three hedges keep their tallies. Read them, and name the '
          'lantern the draught changed.'),
      findsOne,
    );
  });

  testWidgets('lists every evening, and labels the double one',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('one lantern changed, somewhere'), findsNWidgets(3));
    expect(find.textContaining('that is the lesson'), findsOne);
    expect(find.text('perhaps nothing happened at all'), findsOne);
  });

  testWidgets('shows an evening read clean', (tester) async {
    await open(tester, best: await keeper({'read.$_first': 0}));
    expect(find.text('read clean'), findsOne);
  });

  testWidgets('tapping an evening opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.evening.name, _first);
  });

  testWidgets('writes a settled evening down with its slips and askings',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await name(tester, 1);
    await tester.pump();

    expect(best.slipsFor(_first), 0);
  });

  testWidgets('an evening left unread writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await name(tester, 4);

    expect(best.done, 0);
  });
}

String get _first => Evenings.at(0).name;
