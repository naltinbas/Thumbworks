import 'package:flutter_test/flutter_test.dart';
import 'package:hurdlecote/best.dart';
import 'package:hurdlecote/fold/greens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fold.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the cote of greens', () {
    testWidgets('names the game and every green', (tester) async {
      await open(tester);
      expect(find.text('Hurdlecote'), findsOne);
      for (var number = 0; number < Greens.count; number++) {
        expect(find.text(Greens.at(number).name), findsOne);
      }
    });

    testWidgets('the third acre is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('no fence of any size ever will'),
        findsOne,
      );
    });

    testWidgets('a penned green wears its count', (tester) async {
      await open(tester,
          best: await keeper({'penned.The Half Acre': 3}));
      expect(find.text('penned with 3'), findsOne);
    });

    testWidgets('a row opens its green', (tester) async {
      await open(tester);
      await tester.tap(find.text(Greens.at(2).name));
      await tester.pump();
      expect(state(tester).play.green.name, Greens.at(2).name);
    });

    testWidgets('leaving a green lands back on the cote',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the greens'));
      await tester.pump();
      expect(find.text('Hurdlecote'), findsOne);
    });
  });
}
