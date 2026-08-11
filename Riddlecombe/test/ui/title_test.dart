import 'package:flutter_test/flutter_test.dart';
import 'package:riddlecombe/weave/meshes.dart';

import '../support/weave.dart';

void main() {
  group('the shed of meshes', () {
    testWidgets('names the game and every mesh', (tester) async {
      await open(tester);
      expect(find.text('Riddlecombe'), findsOne);
      for (var number = 0; number < Meshes.count; number++) {
        expect(find.text(Meshes.at(number).name), findsOne);
      }
    });

    testWidgets('the short weave is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no weave of them riddles'), findsOne);
    });

    testWidgets('a row opens its mesh', (tester) async {
      await open(tester);
      await tester.tap(find.text(Meshes.at(1).name));
      await tester.pump();
      expect(state(tester).play.mesh.name, Meshes.at(1).name);
    });

    testWidgets('leaving a mesh lands back on the shed', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the meshes'));
      await tester.pump();
      expect(find.text('Riddlecombe'), findsOne);
    });
  });
}
