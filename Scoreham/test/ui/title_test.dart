import 'package:flutter_test/flutter_test.dart';
import 'package:scoreham/best.dart';
import 'package:scoreham/score/rings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/score.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the ham of rings', () {
    testWidgets('names the game and every ring', (tester) async {
      await open(tester);
      expect(find.text('Scoreham'), findsOne);
      for (var number = 0; number < Rings.count; number++) {
        expect(find.text(Rings.at(number).name), findsOne);
      }
    });

    testWidgets('the tied vote is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('and there is none'),
        findsOne,
      );
    });

    testWidgets('a settled ring wears its tries', (tester) async {
      await open(tester,
          best: await keeper({'found.The Five Marks': 1}));
      expect(find.text('found in 1'), findsOne);
    });

    testWidgets('a row opens its ring', (tester) async {
      await open(tester);
      await tester.tap(find.text(Rings.at(2).name));
      await tester.pump();
      expect(state(tester).play.ring.name, Rings.at(2).name);
    });

    testWidgets('leaving a ring lands back on the ham',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the rings'));
      await tester.pump();
      expect(find.text('Scoreham'), findsOne);
    });
  });
}
