import 'package:flutter_test/flutter_test.dart';

import 'support/fence.dart';
import 'support/fonts.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh stile names itself and its task', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Even Fence'), findsOneWidget);
    expect(
      find.textContaining('peg 5 and show exactly 1 gap length'),
      findsOneWidget,
    );
    // One over two: two pegs of the five stand apart.
    expect(
      find.textContaining('Only 2 of the 5 pegs stand apart'),
      findsOneWidget,
    );
  });

  testWidgets('dialing to one over five lands the even fence',
      (tester) async {
    await open(tester, which: 0);
    await dialTo(tester, 1, 5);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(
      find.textContaining('3 turns of the dial'),
      findsOneWidget,
    );
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('the chips count the gaps by length', (tester) async {
    await open(tester, which: 1);
    await dialTo(tester, 1, 10);
    // Nine pegs on a round of ten: eight gaps of one, one of two.
    expect(find.text('1 hole ×8'), findsOneWidget);
    expect(find.text('2 holes ×1'), findsOneWidget);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('back takes back a turn and unfreezes the dial',
      (tester) async {
    await open(tester, which: 0);
    await dialTo(tester, 1, 5);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(state(tester).play.round, 4);
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me points a dial in words', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Dial to 4 over 11.'), findsOneWidget);
  });

  testWidgets('why speaks the sweep and the stile\'s ways',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(find.textContaining('all 1,980 fences'), findsOneWidget);
    expect(
      find.textContaining('2 dials of the sweep land this stile'),
      findsOneWidget,
    );
    expect(find.textContaining('four over eleven'), findsOneWidget);
  });

  testWidgets('the hopeless stile admits it and speaks the law',
      (tester) async {
    await open(tester, which: 4);
    for (var turn = 0; turn < 10; turn++) {
      await turnRound(tester, 1);
    }
    await turnStride(tester, 1);
    await turnStride(tester, 1);
    expect(state(tester).play.dials, 12);
    expect(find.text('No fourth gap.'), findsOneWidget);
    expect(
      find.textContaining('the gaps take three lengths at most'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('a fourth gap size has never once shown'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the stile over', (tester) async {
    await open(tester, which: 0);
    await dialTo(tester, 1, 5);
    await press(tester, 'Again');
    expect(state(tester).play.dials, 0);
    expect(state(tester).play.round, 2);
    expect(find.text('Landed.'), findsNothing);
  });
}
