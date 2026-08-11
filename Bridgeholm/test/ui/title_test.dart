import 'package:bridgeholm/walk/towns.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/walk.dart';

void main() {
  group('the shelf of towns', () {
    testWidgets('names the game and every town', (tester) async {
      await open(tester);
      expect(find.text('Bridgeholm'), findsOne);
      for (var number = 0; number < Towns.count; number++) {
        expect(find.text(Towns.at(number).name), findsOne);
      }
    });

    testWidgets('the seven bridges are labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no walk crosses them all'), findsOne);
    });

    testWidgets('a row opens its town', (tester) async {
      await open(tester);
      await tester.tap(find.text(Towns.at(1).name));
      await tester.pump();
      expect(state(tester).play.town.name, Towns.at(1).name);
    });

    testWidgets('leaving a town lands back on the shelf', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the towns'));
      await tester.pump();
      expect(find.text('Bridgeholm'), findsOne);
    });
  });
}
