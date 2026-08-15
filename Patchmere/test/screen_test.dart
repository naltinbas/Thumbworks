import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// One quilt on the screen, sewn as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a level opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('sew last on the three-by-four quilt, sewing first'),
      findsOneWidget,
    );
    expect(find.text('patches 0 yours, 0 the house'), findsOneWidget);
    expect(find.text('tree: you sew last'), findsOneWidget);
    expect(find.text('house: waiting'), findsOneWidget);
    expect(find.text('Your patch; the tree says you sew last.'), findsOneWidget);
  });

  testWidgets('the house sews first on the two by six', (tester) async {
    await open(tester, which: 0);
    expect(find.text('patches 0 yours, 1 the house'), findsOneWidget);
    expect(find.text('house: any'), findsOneWidget);
    expect(find.text('The house: any. Your patch; the tree says you sew last.'), findsOneWidget);
  });

  testWidgets('a tap picks, a second sews, the house answers, and back undoes', (tester) async {
    await open(tester, which: 1);
    await tapCell(tester, 5);
    expect(state(tester).play.held, 5);
    expect(find.text('Cell picked; tap a free neighbour to sew.'), findsOneWidget);
    await tapCell(tester, 6);
    expect(state(tester).play.moves, 1);
    expect(state(tester).play.patches.first, ((5, 6), true));
    expect(find.text('patches 1 yours, 1 the house'), findsOneWidget);
    expect(find.textContaining('The house: any.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.moves, 0);
    expect(find.text('house: waiting'), findsOneWidget);
  });

  testWidgets('mirroring sews the two by six out and shows the card', (tester) async {
    await open(tester, which: 0);
    await sewByPointer(tester);
    expect(state(tester).play.won, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('You sewed last: the house has no patch left.'), findsOneWidget);
    expect(find.text('patches 3 yours, 3 the house'), findsOneWidget);
    expect(
      find.textContaining('You sewed the last patch; 3 patches of yours.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings the middle patch', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, (5, 6));
    expect(find.text('Sew the ringed pair.'), findsOneWidget);
  });

  testWidgets('the four by five lands by the pointer', (tester) async {
    await open(tester, which: 3);
    await sewByPointer(tester);
    expect(state(tester).play.won, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
  });

  testWidgets('a wrong opening is lost, and the house sews last', (tester) async {
    await open(tester, which: 1);
    await sew(tester, (0, 1));
    expect(find.text('tree: the house sews last'), findsOneWidget);
    await sewAnyhow(tester);
    expect(state(tester).play.lost, isTrue);
    expect(find.text('The house sewed last: no patch left for you.'), findsOneWidget);
    expect(find.text('The house sewed last.'), findsOneWidget);
    expect(find.textContaining('the thread was there to keep'), findsOneWidget);
  });

  testWidgets('the hopeless quilt cracks when it is sewn out', (tester) async {
    await open(tester, which: 4);
    await sewAnyhow(tester);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('house: mirror'), findsOneWidget);
    expect(find.text('The house never runs out.'), findsOneWidget);
    expect(
      find.textContaining('every patch of yours has a free mirror across the middle'),
      findsOneWidget,
    );
  });

  testWidgets('the why pins the middle', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('no patch is its own mirror'),
      findsOneWidget,
    );
    expect(
      find.textContaining('none of the 3,648 games is yours'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the three by three reads the tree alone', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('8 of the 10 are yours'),
      findsOneWidget,
    );
    expect(
      find.textContaining('whoever sews first on the three-by-three loses'),
      findsOneWidget,
    );
  });
}
