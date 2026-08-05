import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handfast/best.dart';
import 'package:handfast/hire/fairs.dart';

import '../support/hire.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many fairs there are', (tester) async {
    await open(tester);
    expect(find.text('${Days.count} fairs'), findsOne);
    expect(
      find.text('${Days.at(6).fair.jobs} jobs · '
          '${Days.at(6).fair.people} hands · '
          '${Days.at(6).most} can be covered'),
      findsOne,
    );
  });

  testWidgets('and how many have been given out', (tester) async {
    await open(tester, best: await keeper({'hired.$_first': 6}));
    expect(find.text('1 of ${Days.count} given out'), findsOne);
    expect(find.text('covered'), findsWidgets);
  });

  testWidgets('tapping a fair opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).day.name, _first);
  });

  testWidgets('writes a day down when nothing else can be given out',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 3, best: best);
    expect(best.done, 0);

    await giveItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.coveredFor(Days.at(3).name), Days.at(3).most);
  });

  testWidgets('and keeps the better of two goes at the same day',
      (tester) async {
    final best = await keeper();
    expect(await best.record(_first, 4), isTrue);
    expect(await best.record(_first, 3), isFalse);
    expect(await best.record(_first, 6), isTrue);
    expect(best.coveredFor(_first), 6);
  });

  testWidgets('a day left half given out writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 4, best: best);

    await tapCell(tester, 0, 0);

    expect(best.done, 0);
  });
}

String get _first => Days.at(0).name;
