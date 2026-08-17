import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/tossland.dart';

/// One ask on the screen, the standings marked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(
        find.textContaining('mark a rule that walks away ahead on more than '
            'half the 32 runs'),
        findsOneWidget);
    expect(find.text('ahead 16 of 32'), findsOneWidget);
    expect(find.text('the purses add to 0'), findsOneWidget);
    expect(find.text('marks 0'), findsOneWidget);
    expect(
        find.text('Ahead on 16 of the 32 runs, at worst 5 down, and the '
            'purses add to 0.'),
        findsOneWidget);
  });

  testWidgets('a mark stops the runs that reach it, and back undoes it',
      (tester) async {
    await open(tester, which: 3);
    await mark(tester, (1, -1));
    expect(state(tester).play.marked((1, -1)), isTrue);
    expect(find.text('marks 1'), findsOneWidget);
    expect(find.text('the purses add to 0'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.stop, isEmpty);
    expect(find.text('marks 0'), findsOneWidget);
  });

  testWidgets('a standing no run reaches says so', (tester) async {
    await open(tester, which: 3);
    await mark(tester, (0, 0));
    await mark(tester, (1, 1));
    expect(state(tester).play.moves, 1);
    expect(
        find.text('No run can reach the standing after 1 toss at 1 up under '
            'this rule, so there is nothing to mark there.'),
        findsOneWidget);
  });

  testWidgets('ahead more than half lands in one mark and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await mark(tester, (1, 1));
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Walked.'), findsOneWidget);
    expect(
        find.text('As asked. Ahead on 21 of the 32 runs, at worst 5 down, and '
            'the purses add to 0.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'The rule walks away ahead on 21 of the 32 runs, at best 3 up and '
            'at worst 5 down, and the 32 purses add to nothing, walked run by '
            'run and folded backward from the last row alike; one of 144 '
            'rules of the 802 that land it; 1 mark.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Walked.'), findsNothing);
    expect(find.text('marks 0'), findsOneWidget);
  });

  testWidgets('show me names the standing, and the pointer lands the halves',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.textContaining('Mark the standing after 1 toss at '),
        findsOneWidget);
    await markByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 2);
    expect(state(tester).play.ends.toSet(), {1, -1});
    expect(find.textContaining('one of 1 rule of the 802 that lands it; '
        '2 marks.'), findsOneWidget);
  });

  testWidgets('ahead two in three is the most a rule can be', (tester) async {
    await open(tester, which: 2);
    await markAll(tester, [(1, 1), (3, 1)]);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.ahead, 22);
    expect(state(tester).play.added, 0);
    expect(find.textContaining('one of 6 rules of the 802'), findsOneWidget);
  });

  testWidgets('the guarded rule takes three marks', (tester) async {
    await open(tester, which: 3);
    await markAll(tester, [(1, 1), (2, -2), (4, -2)]);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 3);
    expect(state(tester).play.worst, -2);
    expect(find.textContaining('one of 5 rules of the 802'), findsOneWidget);
  });

  testWidgets('the sure thing gives itself up after four rules',
      (tester) async {
    await open(tester, which: 4);
    await markAll(tester, [(4, 4), (4, 2), (4, 0), (4, -2)]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Nothing, whatever you mark.'), findsOneWidget);
    expect(
        find.text('Every standing is worth just what it holds, so the purse '
            'comes out at nothing however you mark the board.'),
        findsOneWidget);
    expect(
        find.textContaining('the 32 purses could only add to nothing by every '
            'one of them being nothing'),
        findsOneWidget);
  });

  testWidgets('the why tells Doob and the two voices', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining("Doob's optional stopping theorem"),
        findsOneWidget);
    expect(
        find.textContaining(
            'works the standings backward from the last row, averaging the '
            'two tosses out of each one'),
        findsOneWidget);
  });
}
