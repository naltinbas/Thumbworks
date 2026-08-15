import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/stileland.dart';

/// One field on the screen, walked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a field opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('walk the three-by-three field from the gate to the mill over the stile at (1, 2)'),
      findsOneWidget,
    );
    expect(find.text('steps 0 of 6'), findsOneWidget);
    expect(find.text('stiles 0 of 1'), findsOneWidget);
    expect(find.text('landings on 9'), findsOneWidget);
    expect(find.text('At the gate; landing routes on from here: 9.'), findsOneWidget);
  });

  testWidgets('steps are taken, the counts follow, back undoes', (tester) async {
    await open(tester, which: 0);
    await stepAll(tester, [(1, 0), (1, 1)]);
    expect(find.text('steps 2 of 6'), findsOneWidget);
    expect(find.text('landings on 3'), findsOneWidget);
    expect(find.text('At (1, 1); landing routes on from here: 3.'), findsOneWidget);
    await tapJunction(tester, (3, 3));
    expect(state(tester).play.walk, hasLength(3));
    await press(tester, 'Back');
    expect(state(tester).play.walk, hasLength(2));
  });

  testWidgets('a pond takes no step', (tester) async {
    await open(tester, which: 1);
    await stepAll(tester, [(1, 0), (2, 0), (2, 1)]);
    expect(state(tester).play.head, (2, 0));
    expect(find.text('At (2, 0); landing routes on from here: 1.'), findsOneWidget);
  });

  testWidgets('the stile is passed and the card shows', (tester) async {
    await open(tester, which: 0);
    await stepAll(tester, [(1, 0), (1, 1), (1, 2), (2, 2), (3, 2), (3, 3)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('The mill, and every stile passed.'), findsOneWidget);
    expect(find.text('stiles 1 of 1'), findsOneWidget);
    expect(
      find.textContaining('Gate to mill, every stile passed, no pond; 6 steps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a stile missed ends the walk short', (tester) async {
    await open(tester, which: 0);
    await stepAll(tester, [(1, 0), (2, 0), (3, 0), (3, 1), (3, 2), (3, 3)]);
    expect(state(tester).play.missed, isTrue);
    expect(find.text('The mill, but the stile at (1, 2) was missed.'), findsOneWidget);
    expect(find.text('A stile missed.'), findsOneWidget);
    expect(find.textContaining('9 of the 20'), findsOneWidget);
  });

  testWidgets('show me rings the next junction, and points back off a strayed walk', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('step', (1, 0)));
    expect(find.text('Step to the ringed junction.'), findsOneWidget);
    await stepAll(tester, [(1, 0), (2, 0)]);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('back', (2, 0)));
    expect(find.text('Step back: no landing route runs on from here.'), findsOneWidget);
  });

  testWidgets('the pointer lands the long field', (tester) async {
    await open(tester, which: 3);
    await walkByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('steps 9 of 9'), findsOneWidget);
  });

  testWidgets('the hopeless field cracks at the mill', (tester) async {
    await open(tester, which: 4);
    await stepAll(tester, [(1, 0), (1, 1), (1, 2), (1, 3), (2, 3), (3, 3), (4, 3), (4, 4)]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Right or up never passes both.'), findsOneWidget);
    expect(
      find.textContaining('neither stile lies right-and-up of the other'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the walk three ways', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('every one of the 70 routes was walked to be sure'),
      findsOneWidget,
    );
    expect(
      find.textContaining('whichever you pass first, the other is behind you'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the pond names Pascal', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('The routes are counted three ways that must agree'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Nine of the 20 routes stand on (2, 1)'),
      findsOneWidget,
    );
  });
}
