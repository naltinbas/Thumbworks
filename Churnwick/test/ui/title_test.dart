import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:churnwick/best.dart';
import 'package:churnwick/churn/dairies.dart';

import '../support/churn.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many mornings there are', (tester) async {
    await open(tester);
    expect(find.text('${Mornings.count} mornings'), findsOne);
    expect(
      find.text('${Mornings.at(0).dairy.churns.join(' and ')} · '
          '${Mornings.at(0).dairy.want} wanted'),
      findsOne,
    );
  });

  testWidgets('and says which dairies can only reach some amounts',
      (tester) async {
    await open(tester);
    expect(find.textContaining('nothing but 2s'), findsWidgets);
  });

  testWidgets('and how many have been measured', (tester) async {
    await open(tester, best: await keeper({'measured.$_first': 6}));
    expect(find.text('1 of ${Mornings.count} measured'), findsOne);
    expect(find.text('goes'), findsOneWidget);
  });

  testWidgets('tapping a morning opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).morning.name, _first);
  });

  testWidgets('writes a morning down once the milk is standing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await measureItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.goesFor(Mornings.at(0).name), Mornings.at(0).fewest);
  });

  testWidgets('and one left part way writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await fill(tester, 1);

    expect(best.done, 0);
  });
}

String get _first => Mornings.at(0).name;
