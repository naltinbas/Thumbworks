import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staddlestone/best.dart';
import 'package:staddlestone/mill/yards.dart';

import '../support/mill.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many yards there are', (tester) async {
    await open(tester);
    expect(find.text('${Yards.count} yards'), findsOne);
    expect(
      find.text('${Yards.at(0).stones} stones · ${Yards.at(0).fewest} moves'),
      findsOne,
    );
  });

  testWidgets('and how many stacks are home', (tester) async {
    await open(tester, best: await keeper({'home.$_first': 3}));
    expect(find.text('1 of ${Yards.count} home'), findsOne);
    expect(find.text('moves'), findsWidgets);
  });

  testWidgets('tapping a yard opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.yard.name, _first);
  });

  testWidgets('writes a yard down once the stack is home', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await workItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.movesFor(Yards.at(0).name), Yards.at(0).fewest);
  });

  testWidgets('and one left part way writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);

    await move(tester, 0, 2);

    expect(best.done, 0);
  });
}

String get _first => Yards.at(0).name;
