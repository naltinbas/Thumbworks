import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pyxholm/assay/boxes.dart';
import 'package:pyxholm/best.dart';

import '../support/assay.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many boxes there are', (tester) async {
    await open(tester);
    expect(find.text('${Boxes.count} boxes'), findsOne);
    expect(
      find.text('${Boxes.at(2).coins} coins · '
          'the wrong one is light · '
          '${Boxes.at(2).verdicts} to tell apart'),
      findsOne,
    );
  });

  testWidgets('and how many have been settled', (tester) async {
    await open(tester, best: await keeper({'assayed.$_first': 2}));
    expect(find.text('1 of ${Boxes.count} settled'), findsOne);
    expect(find.text('weighings'), findsOneWidget);
  });

  testWidgets('tapping a box opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).pyx.name, _first);
  });

  testWidgets('writes a box down once the coin is found', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await settleItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.weighingsFor(Boxes.at(0).name), Boxes.at(0).fewest);
  });

  testWidgets('and a box left half settled writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 3, best: best);

    await weigh(tester, [0], [1]);

    expect(best.done, 0);
  });
}

String get _first => Boxes.at(0).name;
