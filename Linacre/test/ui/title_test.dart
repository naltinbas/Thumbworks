import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linacre/best.dart';
import 'package:linacre/wire/rounds.dart';

import '../support/wire.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many rounds there are and how many can be won',
      (tester) async {
    await open(tester);
    expect(find.text('7 rounds, 6 of them winnable'), findsOne);
  });

  testWidgets('labels the hopeless round on the list', (tester) async {
    await open(tester);
    expect(find.text('you cut, and it cannot be won'), findsOneWidget);
  });

  testWidgets('and how many have been won', (tester) async {
    await open(tester, best: await keeper({'won.$_first': 2}));
    expect(find.text('1 of 6 won'), findsOne);
  });

  testWidgets('tapping a round opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.round.name, _first);
  });

  testWidgets('writes a round down once it is won', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await winItAll(tester);
    await tester.pump();

    expect(state(tester).play.won, isTrue);
    expect(best.movesFor(Rounds.at(1).name), Rounds.at(1).fewest);
  });

  testWidgets('and a round lost writes down nothing', (tester) async {
    final hopeless = Rounds.all.indexWhere((round) => round.hopeless);
    final best = await keeper();
    await open(tester, which: hopeless, best: best);

    var guard = 0;
    while (!state(tester).play.isOver) {
      if (guard++ > 12) fail('it never ended');
      final play = state(tester).play;
      final free = [
        for (var wire = 0; wire < play.net.many; wire++)
          if (play.isFree(wire)) wire,
      ];
      await touch(tester, free.first);
    }
    expect(best.done, 0);
  });
}

String get _first => Rounds.at(0).name;
