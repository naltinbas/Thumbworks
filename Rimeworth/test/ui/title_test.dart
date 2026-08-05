import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rimeworth/best.dart';
import 'package:rimeworth/round/parishes.dart';

import '../support/round.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many parishes there are', (tester) async {
    await open(tester);
    expect(find.text('${Grittings.count} parishes'), findsOne);
    expect(
      find.text('${Grittings.at(0).parish.count} junctions · '
          '${Grittings.at(0).parish.laneCount} lanes · '
          '${Grittings.at(0).parish.oddJunctions.length} odd'),
      findsOne,
    );
  });

  testWidgets('and how few runs each has been salted in', (tester) async {
    await open(tester, best: await keeper({'salted.$_first': 1}));
    expect(find.text('1 of ${Grittings.count} salted'), findsOne);
    expect(find.text('runs'), findsOneWidget);
  });

  testWidgets('tapping a parish opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).gritting.name, _first);
  });

  testWidgets('writes a parish down once every lane is salted', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await saltItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.runsFor(Grittings.at(1).name), Grittings.at(1).runs);
  });

  testWidgets('and a parish left half salted writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await drive(tester, 1);
    await drive(tester, 0);

    expect(best.done, 0);
  });
}

String get _first => Grittings.at(0).name;
