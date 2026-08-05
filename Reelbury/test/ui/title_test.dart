import 'package:flutter_test/flutter_test.dart';
import 'package:reelbury/best.dart';
import 'package:reelbury/reel/rounds.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/reel.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many rounds there are', (tester) async {
    await open(tester);
    expect(find.text('${Rounds.count} rounds'), findsOne);
    expect(find.textContaining('${Rounds.at(0).count} couples'), findsWidgets);
  });

  testWidgets('and how few changes each has been paired up in',
      (tester) async {
    await open(tester, best: await keeper({'paired.$_first': 3}));
    expect(find.text('1 of ${Rounds.count} paired up'), findsOne);
    expect(find.text('changes'), findsWidgets);
  });

  testWidgets('tapping a round opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).round.name, _first);
  });

  testWidgets('writes a round down once it holds', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await pairThemUp(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.changesFor(_first), Rounds.at(0).count,
        reason: 'one change a couple, with nothing broken');
  });

  testWidgets('and a floor left half paired writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await pair(tester, 0, 1);

    expect(best.done, 0);
  });
}

String get _first => Rounds.at(0).name;
