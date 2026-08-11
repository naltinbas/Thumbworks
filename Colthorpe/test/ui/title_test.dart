import 'package:colthorpe/best.dart';
import 'package:colthorpe/tour/yards.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/tour.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Colthorpe'), findsOne);
    expect(
      find.text('Ride the colt through every paddock exactly once.'),
      findsOne,
    );
  });

  testWidgets('lists every yard, and labels the ones no round rides',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('3 by 4, open'), findsOne);
    expect(find.text('6 by 6, home again'), findsOne);
    expect(find.textContaining('no round rides it'), findsNWidgets(2));
  });

  testWidgets('shows a yard ridden', (tester) async {
    await open(tester, best: await keeper({'ridden.$_first': 0}));
    expect(find.text('ridden unasked'), findsOne);
  });

  testWidgets('tapping a yard opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.yard.name, _first);
  });

  testWidgets('writes a ridden round down with its askings', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await rideItAll(tester);
    await tester.pump();

    expect(best.askingsFor(_first), isNotNull);
  });

  testWidgets('a round left part ridden writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await ride(tester, 5);

    expect(best.done, 0);
  });
}

String get _first => Yards.at(0).name;
