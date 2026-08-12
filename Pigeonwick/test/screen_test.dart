import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wick.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh round names itself and its task', (tester) async {
    await open(tester, which: 1);
    expect(find.text('The Nine'), findsOneWidget);
    expect(
      find.textContaining('post all 4 letters with none home'),
      findsOneWidget,
    );
    expect(find.text('4 letters in the bag.'), findsOneWidget);
  });

  testWidgets('a letter picks up and posts', (tester) async {
    await open(tester, which: 1);
    await tapLetter(tester, 0);
    expect(
      find.text('Letter 1 in hand; tap a hole.'),
      findsOneWidget,
    );
    await tapHole(tester, 1);
    expect(state(tester).play.posting[0], 1);
    expect(find.text('posted 1 of 4'), findsOneWidget);
  });

  testWidgets('a home letter is called out', (tester) async {
    await open(tester, which: 1);
    await post(tester, 0, 0);
    expect(find.text('Letter 1 sits home.'), findsOneWidget);
    expect(find.text('home 1'), findsOneWidget);
  });

  testWidgets('a full derangement lands and records', (tester) async {
    await open(tester, which: 1);
    await postAll(tester, const [1, 0, 3, 2]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Posted.'), findsOneWidget);
    expect(find.textContaining('4 postings all told'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('back takes back a posting and unfreezes',
      (tester) async {
    await open(tester, which: 1);
    await postAll(tester, const [1, 0, 3, 2]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Posted.'), findsNothing);
  });

  testWidgets('show me names the letter and the hole', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    expect(
      find.text('Post letter ${aim!.$1 + 1} to hole '
          '${aim.$2 + 1}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the three voices', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('the recurrence builds the count'),
      findsOneWidget,
    );
    expect(find.textContaining('5! over e'), findsOneWidget);
    expect(find.textContaining('44 rounds land'), findsOneWidget);
  });

  testWidgets('the hopeless round admits it and speaks the hole',
      (tester) async {
    await open(tester, which: 4);
    for (var posting = 0; posting < 6; posting++) {
      await post(tester, 0, 1);
      await tapHole(tester, 1);
    }
    expect(state(tester).play.moves, 12);
    expect(
      find.text('The third stays out of reach.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('leaves the fourth only its own hole'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('three home is four home'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the round over', (tester) async {
    await open(tester, which: 1);
    await postAll(tester, const [1, 0, 3, 2]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Posted.'), findsNothing);
  });
}
