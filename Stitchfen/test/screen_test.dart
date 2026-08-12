import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/sampler.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh row names itself and its ladder', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Six'), findsOneWidget);
    expect(
      find.textContaining('thread 6 stitches with no ladder'),
      findsOneWidget,
    );
    expect(
      find.text('Stitches 1, 2 and 3 ladder in madder.'),
      findsOneWidget,
    );
  });

  testWidgets('a tap flips a stitch and the ladders recount',
      (tester) async {
    await open(tester, which: 0);
    await tapStitch(tester, 1);
    expect(state(tester).play.threads[1], 'B');
    expect(state(tester).play.moves, 1);
    expect(find.textContaining('ladders'), findsOneWidget);
  });

  testWidgets('a good six lands and records', (tester) async {
    await open(tester, which: 0);
    await threadAll(tester, 'RRBBRR');
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Threaded.'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('the fixed stitches refuse the finger', (tester) async {
    await open(tester, which: 3);
    await tapStitch(tester, 0);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('back takes back a flip and unfreezes', (tester) async {
    await open(tester, which: 0);
    await threadAll(tester, 'RRBBRR');
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Threaded.'), findsNothing);
  });

  testWidgets('show me names the stitch and the thread',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    expect(
      find.text('Flip stitch ${aim!.$1 + 1} to '
          '${aim.$2 == 'R' ? 'madder' : 'indigo'}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the sweep and the prefix ledger',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('sweep threads all 256 rows'),
      findsOneWidget,
    );
    expect(
      find.textContaining('prefix ledger that re-adds it'),
      findsOneWidget,
    );
    expect(
      find.textContaining('three patterns and their thread-swaps'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless row admits it and speaks the wall',
      (tester) async {
    await open(tester, which: 4);
    for (var flip = 0; flip < 12; flip++) {
      await tapStitch(tester, flip % 9);
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The ninth stitch ladders.'), findsOneWidget);
    expect(
      find.textContaining('all 512 rows of nine'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('Van der Waerden'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the row over', (tester) async {
    await open(tester, which: 0);
    await threadAll(tester, 'RRBBRR');
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Threaded.'), findsNothing);
  });
}
