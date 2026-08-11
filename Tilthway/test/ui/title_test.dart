import 'package:flutter_test/flutter_test.dart';
import 'package:tilthway/tilth/tilths.dart';

import '../support/tilth.dart';

void main() {
  group('the field of tilths', () {
    testWidgets('names the game and every tilth', (tester) async {
      await open(tester);
      expect(find.text('Tilthway'), findsOne);
      for (var number = 0; number < Tilths.count; number++) {
        expect(find.text(Tilths.at(number).name), findsOne);
      }
    });

    testWidgets('the dead board is labelled dead on the way in', (
      tester,
    ) async {
      await open(tester);
      expect(find.textContaining('dead where it lies'), findsOne);
    });

    testWidgets('a row opens its tilth', (tester) async {
      await open(tester);
      await tester.tap(find.text(Tilths.at(1).name));
      await tester.pump();
      expect(state(tester).play.tilth.name, Tilths.at(1).name);
    });

    testWidgets('leaving a tilth lands back on the field', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the tilths'));
      await tester.pump();
      expect(find.text('Tilthway'), findsOne);
    });
  });
}
