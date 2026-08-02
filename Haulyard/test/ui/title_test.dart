import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haulyard/best.dart';
import 'package:haulyard/yard/levels.dart';

import '../support/yard.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('lists every yard with its idea and its par', (tester) async {
    await open(tester);
    for (var i = 0; i < Levels.count; i++) {
      expect(find.text(Levels.at(i).name), findsOne);
      expect(find.text(Levels.at(i).about), findsOne);
    }
    expect(find.text('${Levels.count} yards'), findsOne);
  });

  testWidgets('shows the fewest shoves a yard has been done in',
      (tester) async {
    await open(tester, best: await keeper({'best.The first one': 3}));
    expect(find.text('3'), findsWidgets);
    expect(find.text('1 of ${Levels.count} done'), findsOne);
  });

  testWidgets('writes down a finish, once the yard is actually finished',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);
    expect(best.done, 0);

    await workItThrough(tester);
    await tester.pump();

    expect(best.shovesFor(Levels.at(1).name), Levels.at(1).par);
  });

  testWidgets('and a yard left half done writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 1, best: best);

    await press(tester, 'Show me');
    await tester.pump();

    expect(best.done, 0);
  });
}
