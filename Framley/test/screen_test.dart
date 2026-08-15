import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wallland.dart';

/// One wall on the screen, hung as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a wall opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('hang the last five frames on the thirty-two by thirty-three wall'), findsOneWidget);
    expect(find.text('hung 4 of 9'), findsOneWidget);
    expect(find.text('bare 211'), findsOneWidget);
    expect(find.text('hangings 0'), findsOneWidget);
    expect(find.textContaining('4 of 9 hung, 211 cells bare'), findsOneWidget);
  });

  testWidgets('a frame is taken, hung and lifted, and back undoes', (tester) async {
    await open(tester, which: 1);
    await takeFrame(tester, 18);
    expect(state(tester).play.held, 18);
    expect(find.text('Holding the 18: tap the wall where its top left corner goes.'), findsOneWidget);
    await tapCell(tester, 20, 0);
    expect(find.text('The 18 does not fit there: it must lie inside the wall over bare cells.'), findsOneWidget);
    await tapCell(tester, 0, 0);
    expect(state(tester).play.hung[18], (0, 0));
    expect(find.text('hangings 1'), findsOneWidget);
    expect(find.text('bare 732'), findsOneWidget);
    await tapCell(tester, 3, 3);
    expect(state(tester).play.hung, isEmpty);
    await press(tester, 'Back');
    expect(state(tester).play.hung[18], (0, 0));
  });

  testWidgets('the last five land and the card is shown', (tester) async {
    await open(tester, which: 0);
    await hang(tester, 4, 18, 14);
    await hang(tester, 7, 15, 18);
    await hang(tester, 1, 22, 24);
    await hang(tester, 9, 23, 24);
    await hang(tester, 8, 15, 25);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Hung.'), findsOneWidget);
    expect(find.text('Hung: 9 frames, no two alike, and the wall is full, 32 by 33.'), findsOneWidget);
    expect(find.textContaining('fill the 32 by 33 wall exactly, 1056 cells; 5 hangings.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Hung.'), findsNothing);
    expect(state(tester).play.hung.length, 4);
  });

  testWidgets('show me names the frame, then the place', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Take the 18 from the tray.'), findsOneWidget);
    await takeFrame(tester, 18);
    await press(tester, 'Show me');
    expect(find.text('Hang the 18 with its corner at the ringed place.'), findsOneWidget);
  });

  testWidgets('the pointer hangs the other nine', (tester) async {
    await open(tester, which: 2);
    await hangByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('fill the 61 by 69 wall exactly, 4209 cells; 9 hangings.'), findsOneWidget);
  });

  testWidgets('a frame in the way is pointed at to lift', (tester) async {
    await open(tester, which: 3);
    await hang(tester, 3, 0, 0);
    await press(tester, 'Show me');
    expect(find.text('Lift the 3: it is in the way.'), findsOneWidget);
    await hangByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the one on the rim: a full wall with the 1 inside admits it', (tester) async {
    await open(tester, which: 4);
    for (final (s, x, y) in [(18, 0, 0), (14, 18, 0), (4, 18, 14), (10, 22, 14), (15, 0, 18), (7, 15, 18), (1, 22, 24), (9, 23, 24), (8, 15, 25)]) {
      await hang(tester, s, x, y);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The 1 stays inside.'), findsOneWidget);
    expect(find.textContaining('The wall is full and the 1 hangs inside.'), findsOneWidget);
  });

  testWidgets('the why tells the well and the count', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('4 hangings, one but for turning and mirroring'), findsOneWidget);
    expect(find.textContaining('the search with the 1 held to the rim finds nothing'), findsOneWidget);
  });
}
