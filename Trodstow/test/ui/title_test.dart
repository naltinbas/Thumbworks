import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trodstow/best.dart';
import 'package:trodstow/link/parishes.dart';

import '../support/link.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many parishes there are', (tester) async {
    await open(tester);
    expect(find.text('${Rounds.count} parishes'), findsOne);
    expect(
      find.text('${Rounds.at(0).parish.count} hamlets · '
          '${Rounds.at(0).parish.many} paths · '
          '${Rounds.at(0).yards} yards'),
      findsOne,
    );
  });

  testWidgets('and how many are joined up', (tester) async {
    await open(tester, best: await keeper({'joined.$_first': 850}));
    expect(find.text('1 of ${Rounds.count} joined up'), findsOne);
    expect(find.text('yards'), findsWidgets);
  });

  testWidgets('tapping a parish opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).round.name, _first);
  });

  testWidgets('writes a parish down once it is joined up', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await joinItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.yardsFor(Rounds.at(1).name), Rounds.at(1).yards);
  });

  testWidgets('and one left in pieces writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await cut(tester, 0);

    expect(best.done, 0);
  });
}

String get _first => Rounds.at(0).name;
