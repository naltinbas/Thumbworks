import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shroveham/best.dart';
import 'package:shroveham/griddle/batches.dart';

import '../support/griddle.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  testWidgets('names the game and what it asks', (tester) async {
    await open(tester);
    expect(find.text('Shroveham'), findsOne);
    expect(
      find.text('Flip the cakes until they sit in order, in the fewest '
          'flips there are.'),
      findsOne,
    );
  });

  testWidgets('lists every batch with its size and its number',
      (tester) async {
    await open(tester);
    expect(find.text(_first), findsOne);
    expect(find.text('4 cakes, fewest 3'), findsOne);
    expect(find.text('The Slack Batch'), findsOne);
  });

  testWidgets('shows what a batch has been served on', (tester) async {
    await open(tester, best: await keeper({'served.$_first': 3}));
    expect(find.text('served on 3'), findsOne);
  });

  testWidgets('tapping a batch opens it', (tester) async {
    await open(tester);
    await press(tester, _first);
    expect(state(tester).play.batch.name, _first);
  });

  testWidgets('writes a serving down when the batch comes right',
      (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);
    expect(best.done, 0);

    await serveItAll(tester);
    await tester.pump();

    expect(best.flipsFor(_first), Batches.at(0).fewest);
  });

  testWidgets('a batch left mid-flip writes down nothing', (tester) async {
    final best = await keeper();
    await open(tester, which: 0, best: best);

    await flip(tester, 0);

    expect(best.done, 0);
  });
}

String get _first => Batches.at(0).name;
