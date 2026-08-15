import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/cutland.dart';

/// One cellar on the screen, searched as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a cellar opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('find the coin among eight casks in three questions, whatever the cellarman answers'),
      findsOneWidget,
    );
    expect(find.text('questions 0 of 3'), findsOneWidget);
    expect(find.text('casks left 8'), findsOneWidget);
    expect(find.text('needs 3'), findsOneWidget);
    expect(find.text('8 casks might, 3 questions needed; tap a cask to ask whether the coin is among the casks up to it.'), findsOneWidget);
  });

  testWidgets('a question cuts the row, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapCask(tester, 3);
    expect(find.text('questions 1 of 3'), findsOneWidget);
    expect(find.text('casks left 4'), findsOneWidget);
    expect(find.textContaining('He says the right part. 4 casks might, 2 questions needed;'), findsOneWidget);
    await press(tester, 'Back');
    expect(find.text('casks left 8'), findsOneWidget);
  });

  testWidgets('the eight found in three and the card shown', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [3, 5, 6]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Found: cask 8 holds the coin, in 3 questions.'), findsOneWidget);
    expect(
      find.textContaining('Cask 8 holds the coin, found in 3 questions.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a cut off the middle spends the questions', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [0, 1, 2]);
    expect(state(tester).play.missed, isTrue);
    expect(find.text('Not found.'), findsOneWidget);
    expect(find.textContaining('a cut off the middle left him too much'), findsOneWidget);
  });

  testWidgets('show me rings the middle cask', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 3);
    expect(find.text('Ask after the ringed cask, the middle of what is left.'), findsOneWidget);
  });

  testWidgets('the pointer searches the hundred', (tester) async {
    await open(tester, which: 3);
    await searchByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('questions 7 of 7'), findsOneWidget);
    expect(find.text('casks left 1'), findsOneWidget);
  });

  testWidgets('the nine never found in three', (tester) async {
    await open(tester, which: 4);
    await tapAll(tester, [3, 5, 6]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Eight answers, nine casks.'), findsOneWidget);
    expect(
      find.textContaining('some two casks get the same three answers and are never told apart'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the answers', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('3 questions have 8 answers between them'),
      findsOneWidget,
    );
    expect(
      find.textContaining('9 is more than 8, so 3 never serve'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the hundred counts the cuts', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('29 leave a part that 6 questions still search'),
      findsOneWidget,
    );
  });
}
