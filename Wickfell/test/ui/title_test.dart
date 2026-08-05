import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wickfell/best.dart';
import 'package:wickfell/lamps/levels.dart';

import '../support/lamps.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many boards there are', (tester) async {
    await open(tester);
    expect(find.text('${Levels.count} boards'), findsOne);
  });

  testWidgets('and how few presses each has been put out in', (tester) async {
    await open(tester, best: await keeper({'best.First light': 3}));
    expect(find.text('1 of ${Levels.count} put out'), findsOne);
    expect(find.text('your best'), findsWidgets);
  });

  testWidgets('writes down a board, once every lamp is out', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await putItOut(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.pressesFor('First light'), Levels.at(0).presses);
  });

  testWidgets('and a board left half lit writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await pressLamp(tester, 0);
    await tester.pump();

    expect(best.done, 0);
  });
}
