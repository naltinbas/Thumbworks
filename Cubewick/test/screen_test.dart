import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// One hexagon on the screen, tiled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a hexagon opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(
      find.textContaining('tile the hexagon of sides 2, 2 and 2 with lozenges'),
      findsOneWidget,
    );
    expect(find.text('lozenges 0 of 12'), findsOneWidget);
    expect(find.text('bare 24'), findsOneWidget);
    expect(find.text('up 12, down 12'), findsOneWidget);
    expect(find.text('Lozenges 0 of 12; 24 triangles bare.'), findsOneWidget);
  });

  testWidgets('a lozenge is laid by two taps, lifted by one, back undoes', (tester) async {
    await open(tester, which: 0);
    await tapTri(tester, (true, 0, 0));
    expect(state(tester).play.held, (true, 0, 0));
    expect(find.text('One triangle held; tap a bare one beside it.'), findsOneWidget);
    await tapTri(tester, (false, 0, 0));
    expect(state(tester).play.laid, hasLength(1));
    expect(find.text('lozenges 1 of 3'), findsOneWidget);
    expect(find.text('bare 4'), findsOneWidget);
    await tapTri(tester, (false, 0, 0));
    expect(state(tester).play.laid, isEmpty);
    await press(tester, 'Back');
    expect(state(tester).play.laid, hasLength(1));
  });

  testWidgets('the one-box tiles and shows the card', (tester) async {
    await open(tester, which: 0);
    await layAll(tester, [((true, -1, 1), (false, -1, 1)), ((true, 0, 0), (false, -1, 0)), ((true, 0, 1), (false, 0, 0))]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Tiled: 3 lozenges, no triangle bare.'), findsOneWidget);
    expect(find.text('bare 0'), findsOneWidget);
    expect(
      find.textContaining('Every triangle covered; 3 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a lozenge to lay, and one to lift', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing!.$1, 'lay');
    expect(find.text('Lay the ringed lozenge.'), findsOneWidget);
    await lay(tester, ((true, 0, 0), (false, 0, 0)));
    await press(tester, 'Show me');
    expect(state(tester).pointing!.$1, 'lift');
    expect(find.text('Lift the ringed lozenge: it is off the tiling.'), findsOneWidget);
  });

  testWidgets('the pointer tiles the long box', (tester) async {
    await open(tester, which: 3);
    await layByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('lozenges 21 of 21'), findsOneWidget);
  });

  testWidgets('the chipped box sticks and admits it', (tester) async {
    await open(tester, which: 4);
    expect(find.text('up 10, down 12'), findsOneWidget);
    await layAnyhow(tester);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The chipped box never tiles.'), findsOneWidget);
    expect(
      find.textContaining('this hexagon has ten of the one and twelve of the other'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the triangles', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('This hexagon holds 10 pointing up and 12 pointing down'),
      findsOneWidget,
    );
    expect(
      find.textContaining('every one leaves two down triangles bare'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the two box names MacMahon', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('MacMahon\'s product'),
      findsOneWidget,
    );
    expect(
      find.textContaining('twenty stacks of cubes in the two-by-two-by-two box'),
      findsOneWidget,
    );
  });
}
