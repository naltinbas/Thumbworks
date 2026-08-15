import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// One supper on the screen, seated as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a supper opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('seat the four guests at two tables with no quarrel at either, 4 quarrels among them'),
      findsOneWidget,
    );
    expect(find.text('seated 0 of 4'), findsOneWidget);
    expect(find.text('clashes 0'), findsOneWidget);
    expect(find.text('quarrels 4'), findsOneWidget);
    expect(find.text('Seated 0 of 4; no quarrel at a table so far.'), findsOneWidget);
  });

  testWidgets('guests seat, a clash reads, back undoes', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [0, 1]);
    expect(find.text('seated 2 of 4'), findsOneWidget);
    expect(find.text('clashes 1'), findsOneWidget);
    expect(find.text('A and B quarrel and share a table.'), findsOneWidget);
    await tapGuest(tester, 1);
    expect(find.text('clashes 0'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.tables[1], 0);
  });

  testWidgets('the four ring seats and shows the card', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [0, 1, 1, 2, 3, 3]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Seated: every quarrel parted between the tables.'), findsOneWidget);
    expect(
      find.textContaining('Every guest is seated and every quarrel parted; 6 taps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me names the table', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('left', 0));
    expect(find.text('Seat A at the left table.'), findsOneWidget);
  });

  testWidgets('the pointer seats the cube', (tester) async {
    await open(tester, which: 3);
    await seatByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('seated 8 of 8'), findsOneWidget);
  });

  testWidgets('the hopeless supper cracks at thirteen taps', (tester) async {
    await open(tester, which: 4);
    await tapAll(tester, [0, 1, 1, 2, 3, 3, 4]);
    expect(find.text('A and E quarrel and share a table.'), findsOneWidget);
    for (var k = 0; k < 6; k++) {
      await tapGuest(tester, 4);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('An odd ring never parts.'), findsOneWidget);
    expect(
      find.textContaining('an odd ring cannot close without the last sitting with the first'),
      findsOneWidget,
    );
  });

  testWidgets('the why names the ring', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('The walk finds such a ring here'),
      findsOneWidget,
    );
    expect(
      find.textContaining('1,024 maps, the sweep, the walk and the odd ring agree'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the two rings counts the parties', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('which is Konig\'s theorem'),
      findsOneWidget,
    );
    expect(
      find.textContaining('four seatings of the 256'),
      findsOneWidget,
    );
  });
}
