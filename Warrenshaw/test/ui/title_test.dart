import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warrenshaw/best.dart';
import 'package:warrenshaw/chase/maps.dart';

import '../support/chase.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('says how many maps there are', (tester) async {
    await open(tester);
    expect(find.text('${Warrens.count} maps'), findsOne);
    expect(
      find.text('${Warrens.at(0).places.length} places · '
          '${Warrens.at(0).par} moves'),
      findsOne,
    );
  });

  testWidgets('and says outright which one cannot be won', (tester) async {
    await open(tester);
    final last = Warrens.at(Warrens.count - 1);
    expect(last.hopeless, isTrue);
    expect(
      find.text('${last.places.length} places · nobody can win this one'),
      findsOne,
    );
  });

  testWidgets('and how few moves each has been won in', (tester) async {
    await open(tester, best: await keeper({'caught.$_first': 3}));
    expect(find.text('1 of ${Warrens.count} won'), findsOne);
    expect(find.text('your best'), findsWidgets);
  });

  testWidgets('tapping a map opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).warren.name, _first);
  });

  testWidgets('writes down a map once the runner is caught', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await chaseItDown(tester);
    await tester.pump();

    expect(state(tester).play.isDone, isTrue);
    expect(best.movesFor(_first), Warrens.at(0).par);
  });

  testWidgets('and a chase left half run writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await touch(tester, state(tester).play.next!);

    expect(best.done, 0);
  });
}

String get _first => Warrens.at(0).name;
