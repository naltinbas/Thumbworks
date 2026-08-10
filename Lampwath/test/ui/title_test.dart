import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lampwath/best.dart';
import 'package:lampwath/wath/bridges.dart';

import '../support/wath.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many bridges there are', (tester) async {
    await open(tester);
    expect(find.text('${Bridges.count} bridges'), findsOne);
    expect(
      find.text('1, 2, 5, 10 · 17 minutes'),
      findsOne,
    );
  });

  testWidgets('and how many have been crossed', (tester) async {
    await open(tester, best: await keeper({'crossed.$_first': 10}));
    expect(find.text('1 of ${Bridges.count} crossed'), findsOne);
    expect(find.text('minutes'), findsWidgets);
  });

  testWidgets('tapping a bridge opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.bridge.name, _first);
  });

  testWidgets('writes a night down once everybody is over', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await crossItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.minutesFor(Bridges.at(1).name), Bridges.at(1).fewest);
  });

  testWidgets('and a night left part way writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await pick(tester, 0);
    await pick(tester, 1);
    await crossNow(tester);

    expect(best.done, 0);
  });
}

String get _first => Bridges.at(0).name;
