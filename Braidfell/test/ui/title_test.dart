import 'package:flutter_test/flutter_test.dart';
import 'package:braidfell/best.dart';
import 'package:braidfell/braid/yards.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/braid.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the fell of yards', () {
    testWidgets('names the game and every yard', (tester) async {
      await open(tester);
      expect(find.text('Braidfell'), findsOne);
      for (var number = 0; number < Yards.count; number++) {
        expect(find.text(Yards.at(number).name), findsOne);
      }
    });

    testWidgets('the fifty-nine is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('no order ever does'),
        findsOne,
      );
    });

    testWidgets('a braided yard wears its askings', (tester) async {
      await open(tester,
          best: await keeper({'braided.The Three Fleeces': 0}));
      expect(find.text('braided, asking 0'), findsOne);
    });

    testWidgets('a row opens its yard', (tester) async {
      await open(tester);
      await tester.tap(find.text(Yards.at(2).name));
      await tester.pump();
      expect(state(tester).play.yard.name, Yards.at(2).name);
    });

    testWidgets('leaving a yard lands back on the fell',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the yards'));
      await tester.pump();
      expect(find.text('Braidfell'), findsOne);
    });
  });
}
