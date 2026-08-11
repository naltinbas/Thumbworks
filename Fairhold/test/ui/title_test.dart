import 'package:fairhold/best.dart';
import 'package:fairhold/hold/consignments.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/hold.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and its ask', (tester) async {
    await open(tester);
    expect(find.text('Fairhold'), findsOne);
    expect(
      find.text('Stack the four painted crates so every side of the '
          'stack shows all four paints.'),
      findsOne,
    );
  });

  testWidgets('lists every consignment, and labels the short one',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('42 ways in the 1,296'), findsOne);
    expect(find.textContaining('count one paint\'s faces'), findsOne);
  });

  testWidgets('shows a consignment stacked clean', (tester) async {
    await open(tester, best: await keeper({'stacked.$_first': 0}));
    expect(find.text('stacked unasked'), findsOne);
  });

  testWidgets('tapping a consignment opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.consignment.name, _first);
  });

  testWidgets('writes a standing stack down with its askings',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await stackItAll(tester);
    await tester.pump();

    expect(best.askingsFor(_first), isNotNull);
  });

  testWidgets('a consignment left loose writes down nothing',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await tapChip(tester, 0, 0);

    expect(best.done, 0);
  });
}

String get _first => Consignments.at(0).name;
