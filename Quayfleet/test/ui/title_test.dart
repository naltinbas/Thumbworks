import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quayfleet/berth/quays.dart';
import 'package:quayfleet/best.dart';

import '../support/berth.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many days there are', (tester) async {
    await open(tester);
    expect(find.text('${Days.count} days'), findsOne);
    expect(
      find.text('${Days.at(0).quay.count} ships · '
          '${Days.at(0).quay.opens} to ${Days.at(0).quay.shuts} · '
          '${Days.at(0).most} fit'),
      findsOne,
    );
  });

  testWidgets('and how many have been worked', (tester) async {
    await open(tester, best: await keeper({'berthed.$_first': 3}));
    expect(find.text('1 of ${Days.count} worked'), findsOne);
    expect(find.text('berthed'), findsWidgets);
  });

  testWidgets('tapping a day opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).day.name, _first);
  });

  testWidgets('writes a day down when nothing else will fit', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await workItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.shipsFor(Days.at(1).name), Days.at(1).most);
  });

  testWidgets('and keeps the better of two goes at the same day',
      (tester) async {
    final best = await keeper();
    expect(await best.record(_first, 2), isTrue);
    expect(await best.record(_first, 1), isFalse);
    expect(await best.record(_first, 3), isTrue);
    expect(best.shipsFor(_first), 3);
  });

  testWidgets('a day left half worked writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await berth(tester, 5);

    expect(best.done, 0);
  });
}

String get _first => Days.at(0).name;
