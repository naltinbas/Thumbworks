import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wedgeland.dart';

/// One ask on the screen, the dials set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips, four squares flat',
      (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('close a corner of squares'), findsOneWidget);
    expect(find.text('each 90°'), findsOneWidget);
    expect(find.text('sum 360°'), findsOneWidget);
    expect(find.text('settings 0'), findsOneWidget);
    expect(
      find.text('Four squares at the corner make 360 degrees exactly: they lie flat, the square tiling, and no corner rises.'),
      findsOneWidget,
    );
  });

  testWidgets('a setting reads its sum, and back undoes', (tester) async {
    await open(tester, which: 1);
    await tapDial(tester, 0, 5);
    expect((state(tester).play.sides, state(tester).play.faces), (5, 4));
    expect(find.text('sum 432°'), findsOneWidget);
    expect(
      find.text('Four pentagons at the corner make 432 degrees, 72 over: they overlap, and no corner closes.'),
      findsOneWidget,
    );
    await press(tester, 'Back');
    expect(state(tester).play.sides, 4);
    expect(find.text('settings 0'), findsOneWidget);
  });

  testWidgets('three squares close the cube and the card is shown', (tester) async {
    await open(tester, which: 1);
    await tapDial(tester, 1, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Closed.'), findsOneWidget);
    expect(
      find.text('As asked. Three squares at the corner make 270 degrees, 90 to spare: the corner closes into the cube, 6 faces, 12 edges, 8 corners.'),
      findsOneWidget,
    );
    expect(find.textContaining('6 faces, 12 edges and 8 corners, and 8 - 12 + 6 is 2; 1 setting.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Closed.'), findsNothing);
  });

  testWidgets('a corner that closes but is not the one asked stays open', (tester) async {
    await open(tester, which: 2);
    await tapDial(tester, 0, 3);
    expect(state(tester).play.closes, isTrue);
    expect(state(tester).play.isDone, isFalse);
    expect(
      find.text('Four triangles at the corner make 240 degrees, 120 to spare: the corner closes into the octahedron, 8 faces, 12 edges, 6 corners.'),
      findsOneWidget,
    );
    await tapDial(tester, 0, 5);
    await tapDial(tester, 1, 3);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Closed.'), findsOneWidget);
    expect(find.textContaining('the dodecahedron: 12 faces, 30 edges and 20 corners'), findsOneWidget);
  });

  testWidgets('show me rings a dial', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, (0, 3));
    expect(find.text('Set the sides to three.'), findsOneWidget);
  });

  testWidgets('the pointer sets the twenty', (tester) async {
    await open(tester, which: 3);
    await setByPointer(tester);
    await setByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('close the icosahedron: 20 faces, 30 edges and 12 corners'), findsOneWidget);
  });

  testWidgets('the honeycomb never closes', (tester) async {
    await open(tester, which: 4);
    await tapDial(tester, 0, 6);
    for (var k = 0; k < 11; k++) {
      await tapDial(tester, 1, k.isEven ? 3 : 5);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The comb lies flat.'), findsOneWidget);
    expect(find.textContaining('three make the full 360 and lie flat'), findsOneWidget);
  });

  testWidgets('the why counts the sweep and the solids', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('36 settings, and the two readings agree on all of them'), findsOneWidget);
    expect(find.textContaining('a whole positive number for exactly those five, 6, 12, 30, 12 and 30'), findsOneWidget);
    expect(find.textContaining('no corner of hexagons closes, on the sham or anywhere'), findsOneWidget);
  });
}
