import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beaconholt/best.dart';
import 'package:beaconholt/watch/countries.dart';

import '../support/watch.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many countries there are', (tester) async {
    await open(tester);
    expect(find.text('${Watchlands.count} countries'), findsOne);
    expect(
      find.text('${Watchlands.at(0).count} hills · '
          '${Watchlands.at(0).sightlines.length} sightlines · '
          '${Watchlands.at(0).fewest} beacons'),
      findsOne,
    );
  });

  testWidgets('and how few beacons each has been watched with',
      (tester) async {
    await open(tester, best: await keeper({'watched.$_first': 2}));
    expect(find.text('1 of ${Watchlands.count} watched'), findsOne);
    expect(find.text('beacons'), findsWidgets);
  });

  testWidgets('tapping a country opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).land.name, _first);
  });

  testWidgets('writes a country down once every hill is watched',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await lightItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.beaconsFor(Watchlands.at(1).name), Watchlands.at(1).fewest);
  });

  testWidgets('and a country left half dark writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await light(tester, 1);

    expect(best.done, 0);
  });
}

String get _first => Watchlands.at(0).name;
