import 'package:flutter_test/flutter_test.dart';
import 'package:beadlow/best.dart';
import 'package:beadlow/bead/rings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/bead.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the stall of rings', () {
    testWidgets('names the game and every ring', (tester) async {
      await open(tester);
      expect(find.text('Beadlow'), findsOne);
      for (var number = 0; number < Rings.count; number++) {
        expect(find.text(Rings.at(number).name), findsOne);
      }
    });

    testWidgets('the seventh is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('it holds only 6'),
        findsOne,
      );
    });

    testWidgets('a strung ring wears its count', (tester) async {
      await open(tester,
          best: await keeper({'strung.The Three': 4}));
      expect(find.text('strung in 4'), findsOne);
    });

    testWidgets('a row opens its ring', (tester) async {
      await open(tester);
      await tester.tap(find.text(Rings.at(2).name));
      await tester.pump();
      expect(state(tester).play.ring.name, Rings.at(2).name);
    });

    testWidgets('leaving a ring lands back on the stall',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the rings'));
      await tester.pump();
      expect(find.text('Beadlow'), findsOne);
    });
  });
}
