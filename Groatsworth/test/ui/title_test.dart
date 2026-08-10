import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:groatsworth/best.dart';
import 'package:groatsworth/till/rounds.dart';

import '../support/counter.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many customers there are', (tester) async {
    await open(tester);
    expect(find.text('${Rounds.count} customers'), findsOne);
    expect(
      find.text('${Rounds.at(2).spoken} · '
          '${Rounds.at(2).till.name.toLowerCase()} · '
          '${Rounds.at(2).fewest} coins'),
      findsOne,
    );
  });

  testWidgets('and how many have been served', (tester) async {
    await open(tester, best: await keeper({'paid.$_first': 1}));
    expect(find.text('1 of ${Rounds.count} served'), findsOne);
    expect(find.text('coins'), findsWidgets);
  });

  testWidgets('tapping a customer opens them', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.round.name, _first);
  });

  testWidgets('writes a round down once the amount is met', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);
    expect(best.done, 0);

    await payItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.coinsFor(Rounds.at(2).name), Rounds.at(2).fewest);
  });

  testWidgets('and one left short writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 3, best: best);

    await put(tester, 5);

    expect(best.done, 0);
  });
}

String get _first => Rounds.at(0).name;
