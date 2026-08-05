import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carterfen/best.dart';
import 'package:carterfen/round/rounds_list.dart';

import '../support/round.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many rounds there are', (tester) async {
    await open(tester);
    expect(find.text('${Rounds.count} rounds'), findsOne);
    expect(
      find.text('${Rounds.at(0).count} farms · '
          '${Rounds.at(0).shortest} furlongs'),
      findsOne,
    );
  });

  testWidgets('and how short each has been driven', (tester) async {
    await open(tester, best: await keeper({'drove.$_first': 210}));
    expect(find.text('1 of ${Rounds.count} driven'), findsOne);
    expect(find.text('furlongs'), findsWidgets);
  });

  testWidgets('tapping a round opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).round.name, _first);
  });

  testWidgets('writes a round down once the cart is home', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await driveItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.furlongsFor(Rounds.at(1).name), Rounds.at(1).shortest);
  });

  testWidgets('and a round left half driven writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await driveTo(tester, 1);

    expect(best.done, 0);
  });
}

String get _first => Rounds.at(0).name;
