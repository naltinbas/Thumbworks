import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/rickland.dart';

/// One ask on the screen, the posts stood as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 1);
    expect(
        find.textContaining('stand the posts so the field is six acres'),
        findsOneWidget);
    expect(find.text('acres 1 halves'), findsOneWidget);
    expect(find.text('no square corner'), findsOneWidget);
    expect(find.text('posts 0'), findsOneWidget);
    expect(
        find.textContaining('The three markers stand the same distance apart'),
        findsOneWidget);
  });

  testWidgets('a lift and a stand make one move, and back undoes it',
      (tester) async {
    await open(tester, which: 3);
    await tapPeg(tester, (0, 2));
    expect(state(tester).play.lifted, 0);
    expect(find.text('posts 0'), findsOneWidget);
    await tapPeg(tester, (4, 4));
    expect(state(tester).play.posts[0], (4, 4));
    expect(find.text('posts 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.posts[0], (0, 2));
    expect(find.text('posts 0'), findsOneWidget);
  });

  testWidgets('a stand that makes a line says so', (tester) async {
    await open(tester, which: 3);
    await tapPeg(tester, (0, 2));
    await tapPeg(tester, (3, 1));
    expect(state(tester).play.posts[0], (0, 2));
    expect(
        find.text('A post cannot stand there: the three would fall in a '
            'line, or two would share a peg.'),
        findsOneWidget);
  });

  testWidgets('the square corner lands in one post and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 1);
    expect(find.text('Raised.'), findsOneWidget);
    expect(find.text('a square corner'), findsNothing);
    expect(
        find.textContaining('worked out in fractions and roots of three and '
            'settled twice'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Raised.'), findsNothing);
    expect(find.text('posts 0'), findsOneWidget);
  });

  testWidgets('show me names the post, and the pointer lands six acres',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.textContaining('Lift post '), findsOneWidget);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 2);
    expect(state(tester).play.halfAcres, 12);
    expect(find.textContaining('One of 68 fields of the 2,148'), findsOneWidget);
  });

  testWidgets('the widest ring is a corner of the green', (tester) async {
    await open(tester, which: 3);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 3);
    expect(find.textContaining('One of 4 fields of the 2,148'), findsOneWidget);
  });

  testWidgets('the square six wants both at once', (tester) async {
    await open(tester, which: 2);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.halfAcres, 12);
    expect(state(tester).play.squareCorner, isTrue);
    expect(find.textContaining('One of 16 fields of the 2,148'),
        findsOneWidget);
  });

  testWidgets('the uneven three gives itself up after four fields',
      (tester) async {
    await open(tester, which: 4);
    for (final peg in [(4, 4), (0, 0), (4, 0), (3, 3)]) {
      await movePost(tester, state(tester).play.posts[0], peg);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Even, wherever the posts stand.'), findsOneWidget);
    expect(
        find.textContaining('The markers are never uneven.'), findsOneWidget);
  });

  testWidgets('the why tells the diary and the two voices', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining("The Ladies' Diary in 1825"), findsOneWidget);
    expect(
        find.textContaining(
            'turns one marker sixty degrees about another and sees whether '
            'it lands on the third'),
        findsOneWidget);
  });
}
