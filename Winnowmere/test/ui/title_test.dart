import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winnowmere/best.dart';
import 'package:winnowmere/sift/puzzles.dart';

import '../support/sift.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many puzzles there are', (tester) async {
    await open(tester);
    expect(find.text('${Siftings.count} puzzles'), findsOne);
    expect(
      find.text('${Siftings.at(0).lines} lines · '
          '${Siftings.at(0).fewest} comparators'),
      findsOne,
    );
  });

  testWidgets('and says which ones start with comparators already in',
      (tester) async {
    await open(tester);
    final begun = Siftings.at(3);
    expect(
      find.text('${begun.lines} lines · ${begun.fewest} comparators, '
          '${begun.given.length} of them given'),
      findsOne,
    );
  });

  testWidgets('and how few comparators each has been sorted with',
      (tester) async {
    await open(tester, best: await keeper({'sifted.$_first': 1}));
    expect(find.text('1 of ${Siftings.count} sorted'), findsOne);
    expect(find.text('comparators'), findsWidgets);
  });

  testWidgets('tapping a puzzle opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).sifting.name, _first);
  });

  testWidgets('writes a puzzle down once the network sorts', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await sortItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.crossesFor(Siftings.at(1).name), Siftings.at(1).fewest);
  });

  testWidgets('and one left half built writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await put(tester, 0, 1);

    expect(best.done, 0);
  });
}

String get _first => Siftings.at(0).name;
