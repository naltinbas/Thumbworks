import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wardhall/best.dart';
import 'package:wardhall/hall/halls.dart';

import '../support/hall.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the keep of halls', () {
    testWidgets('names the game and every hall', (tester) async {
      await open(tester);
      expect(find.text('Wardhall'), findsOne);
      for (var number = 0; number < Halls.count; number++) {
        expect(find.text(Halls.at(number).name), findsOne);
      }
    });

    testWidgets('the comb short is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('no watch ever has'),
        findsOne,
      );
    });

    testWidgets('a lit hall wears its askings', (tester) async {
      await open(tester, best: await keeper({'lit.The Ell': 0}));
      expect(find.text('lit, asking 0'), findsOne);
    });

    testWidgets('a row opens its hall', (tester) async {
      await open(tester);
      await tester.tap(find.text(Halls.at(2).name));
      await tester.pump();
      expect(state(tester).play.hall.name, Halls.at(2).name);
    });

    testWidgets('leaving a hall lands back on the keep',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the halls'));
      await tester.pump();
      expect(find.text('Wardhall'), findsOne);
    });
  });
}
