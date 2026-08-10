import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shardlow/best.dart';
import 'package:shardlow/drop/ladders.dart';

import '../support/drop.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many ladders there are', (tester) async {
    await open(tester);
    expect(find.text('${Ladders.count} ladders'), findsOne);
    expect(
      find.text('${Ladders.at(1).rungs} rungs · '
          '2 pots · '
          '${Ladders.at(1).fewest} drops'),
      findsOne,
    );
  });

  testWidgets('and how many have been settled', (tester) async {
    await open(tester, best: await keeper({'settled.$_first': 6}));
    expect(find.text('1 of ${Ladders.count} settled'), findsOne);
    expect(find.text('drops'), findsWidgets);
  });

  testWidgets('tapping a ladder opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.ladder.name, _first);
  });

  testWidgets('writes a morning down once it settles', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await settleItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.dropsFor(Ladders.at(1).name), Ladders.at(1).fewest);
  });

  testWidgets('and one left unsettled writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await drop(tester, 5);

    expect(best.done, 0);
  });
}

String get _first => Ladders.at(0).name;
