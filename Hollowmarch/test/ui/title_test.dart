import 'package:flutter_test/flutter_test.dart';
import 'package:hollowmarch/best.dart';
import 'package:hollowmarch/pegs/boards.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/pegs.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many boards there are', (tester) async {
    await open(tester);
    expect(find.text('${Boards.count} boards'), findsOne);
    expect(
      find.text('${Boards.at(0).hollows} hollows · ${Boards.at(0).par} moves'),
      findsOne,
    );
  });

  testWidgets('and says outright that the big one has no fewest known',
      (tester) async {
    await open(tester);
    final big = Boards.at(Boards.count - 1);
    expect(big.par, isNull);
    expect(find.text('${big.hollows} hollows · no fewest known'), findsOne);
  });

  testWidgets('and how few moves each has been finished in', (tester) async {
    await open(tester, best: await keeper({'moves.$_first': 6}));
    expect(find.text('1 of ${Boards.count} finished'), findsOne);
    expect(find.text('your best'), findsWidgets);
  });

  testWidgets('tapping a board opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).board.name, _first);
  });

  testWidgets('writes down a board once it comes down to one peg',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await playItOut(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.movesFor(_first), Boards.at(0).par);
  });

  testWidgets('and a board left half played writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await playSome(tester, 2);

    expect(best.done, 0);
  });
}

String get _first => Boards.at(0).name;
