import 'package:flutter_test/flutter_test.dart';
import 'package:peckhollow/best.dart';
import 'package:peckhollow/yard/yards.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/yard.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the hollow of yards', () {
    testWidgets('names the game and every yard', (tester) async {
      await open(tester);
      expect(find.text('Peckhollow'), findsOne);
      for (var number = 0; number < Yards.count; number++) {
        expect(find.text(Yards.at(number).name), findsOne);
      }
    });

    testWidgets('the two kings is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('no yard ever wears it'),
        findsOne,
      );
    });

    testWidgets('a crowned yard wears its count', (tester) async {
      await open(tester,
          best: await keeper({'crowned.The Three': 1}));
      expect(find.text('crowned in 1'), findsOne);
    });

    testWidgets('a row opens its yard', (tester) async {
      await open(tester);
      await tester.tap(find.text(Yards.at(2).name));
      await tester.pump();
      expect(state(tester).play.yard.name, Yards.at(2).name);
    });

    testWidgets('leaving a yard lands back on the hollow',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the yards'));
      await tester.pump();
      expect(find.text('Peckhollow'), findsOne);
    });
  });
}
