import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weirbank/best.dart';
import 'package:weirbank/flow/works_list.dart';

import '../support/flow.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many works there are', (tester) async {
    await open(tester);
    expect(find.text('${Waterworks.count} works'), findsOne);
    expect(
      find.text('${Waterworks.at(0).ponds.length} ponds · '
          '${Waterworks.at(0).pipes.length} pipes · '
          '${Waterworks.at(0).target} to the mill'),
      findsOne,
    );
  });

  testWidgets('and how few turns each has been set in', (tester) async {
    await open(tester, best: await keeper({'set.$_first': 4}));
    expect(find.text('1 of ${Waterworks.count} running'), findsOne);
    expect(find.text('turns'), findsWidgets);
  });

  testWidgets('tapping a works opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).waterwork.name, _first);
  });

  testWidgets('writes a works down once the mill has its water',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await setItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.turnsFor(_first), state(tester).play.turns);
  });

  testWidgets('and a works left half set writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await turn(tester, 0);

    expect(best.done, 0);
  });
}

String get _first => Waterworks.at(0).name;
