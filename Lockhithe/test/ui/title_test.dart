import 'package:flutter_test/flutter_test.dart';
import 'package:lockhithe/best.dart';
import 'package:lockhithe/quay/berths.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/quay.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Lockhithe'), findsOne);
    expect(
      find.text('Every sailor hunts their own chit, half the lockers '
          'each. The loops decide.'),
      findsOne,
    );
  });

  testWidgets('lists every berth with its crew', (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('4 sailors, 2 looks each'), findsOne);
    expect(find.text('10 sailors, 5 looks each'), findsOne);
  });

  testWidgets('shows a berth come through', (tester) async {
    await open(tester, best: await keeper({'through.$_first': 0}));
    expect(find.text('through unasked'), findsOne);
  });

  testWidgets('tapping a berth opens it', (tester) async {
    await open(tester, dealt: kindStow);
    await press(tester, _first);
    expect(state(tester).play.berth.name, _first);
  });

  testWidgets('writes a crew through down with its askings', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best, dealt: kindStow);
    expect(best.done, 0);

    await followItOut(tester);
    await tester.pump();

    expect(best.askingsFor('The Eight Lockers'), 0);
  });

  testWidgets('a sunk round writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best, dealt: cruelStow);

    await followItOut(tester);
    await tester.pump();

    expect(best.done, 0);
  });
}

String get _first => Berths.at(0).name;
