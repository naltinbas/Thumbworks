import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rungwick/best.dart';
import 'package:rungwick/ladder/climbs.dart';
import 'package:rungwick/ladder/graph.dart';
import 'package:rungwick/ladder/words.dart';

import '../support/climb.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  late Ladder four;

  setUpAll(() => four = Ladder.of(kFour));

  testWidgets('says how many climbs there are', (tester) async {
    await open(tester, ladder: four);
    expect(find.text('${Climbs.count} climbs'), findsOne);
  });

  testWidgets('and how few rungs each has been done in', (tester) async {
    await open(tester, ladder: four, best: await keeper({'best.rake-cons': 4}));
    expect(find.text('1 of ${Climbs.count} climbed'), findsOne);
    expect(find.text('your best'), findsOne);
  });

  testWidgets('writes down a climb, once it is actually finished',
      (tester) async {
    final best = await keeper();
    await open(tester, ladder: four, which: 0, best: best);
    expect(best.climbed, 0);

    await climbIt(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.rungsFor('rake', 'cons'), Climbs.at(0).rungs);
  });

  testWidgets('and a climb left half way up writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, ladder: four, which: 0, best: best);

    await climbTo(tester, 'cake');
    await tester.pump();

    expect(best.climbed, 0);
  });
}
