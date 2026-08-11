import 'package:boardleigh/floor/rooms.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/floor.dart';

void main() {
  group('the house of rooms', () {
    testWidgets('names the game and every room', (tester) async {
      await open(tester);
      expect(find.text('Boardleigh'), findsOne);
      for (var number = 0; number < Rooms.count; number++) {
        expect(find.text(Rooms.at(number).name), findsOne);
      }
    });

    testWidgets('the clipped parlour is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no laying floors it'), findsOne);
    });

    testWidgets('a row opens its room', (tester) async {
      await open(tester);
      await tester.tap(find.text(Rooms.at(2).name));
      await tester.pump();
      expect(state(tester).play.room.name, Rooms.at(2).name);
    });

    testWidgets('leaving a room lands back on the house',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the rooms'));
      await tester.pump();
      expect(find.text('Boardleigh'), findsOne);
    });
  });
}
