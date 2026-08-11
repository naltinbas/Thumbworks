import 'package:flutter_test/flutter_test.dart';
import 'package:pinderwell/best.dart';
import 'package:pinderwell/drive/fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/drive.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Pinderwell'), findsOne);
    expect(
      find.text(
          'Drive the stray ewe to the pen. The last push takes the fee.'),
      findsOne,
    );
  });

  testWidgets('lists every field, and labels the one that cannot be won',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('the ewe 4 east, 2 north, the fee in 2'), findsOne);
    expect(find.textContaining('the pinder cannot be beaten'), findsOne);
  });

  testWidgets('shows what a field has been won on', (tester) async {
    await open(tester, best: await keeper({'penned.$_first': 2}));
    expect(find.text('won on 2'), findsOne);
  });

  testWidgets('tapping a field opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.field.name, _first);
  });

  testWidgets('writes a won drive down', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await winItAll(tester);
    await tester.pump();

    expect(best.pushesFor(_first), Fields.at(0).fewest);
  });

  testWidgets('and a lost drive writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 4, best: best);

    // Hand her straight to the pinder: from three east five north, due
    // west to the wall leaves him the pen in one.
    await push(tester, 0, 5);
    await tester.pump();

    expect(state(tester).play.isOver, isTrue);
    expect(state(tester).play.won, isFalse);
    expect(best.done, 0);
  });
}

String get _first => Fields.at(0).name;
