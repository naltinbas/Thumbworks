import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marchcombe/best.dart';
import 'package:marchcombe/dye/lands.dart';

import '../support/dye.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many estates there are', (tester) async {
    await open(tester);
    expect(find.text('${Estates.count} estates'), findsOne);
    expect(
      find.text('${Estates.at(0).land.count} fields · '
          '${Estates.at(0).land.hedges.length} hedges'),
      findsOne,
    );
  });

  testWidgets('and how many have been painted', (tester) async {
    await open(tester, best: await keeper({'painted.$_first': 2}));
    expect(find.text('1 of ${Estates.count} painted'), findsOne);
  });

  testWidgets('tapping an estate opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).estate.name, _first);
  });

  testWidgets('writes an estate down once it is painted', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await paintItAll(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.dyesFor(Estates.at(1).name), Estates.at(1).fewest);
  });

  testWidgets('and one left half painted writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 2, best: best);

    await paint(tester, 1, 0);

    expect(best.done, 0);
  });
}

String get _first => Estates.at(0).name;
