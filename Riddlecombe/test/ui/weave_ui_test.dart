import 'package:flutter_test/flutter_test.dart';
import 'package:riddlecombe/weave/meshes.dart';

import '../support/weave.dart';

void main() {
  group('the screen', () {
    testWidgets('opens with the frame empty', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.placed, 0);
      expect(find.text('4 of 8 grists run clean'), findsOne);
      expect(find.text('0 / 3'), findsOne);
    });

    testWidgets('two taps weave a comb', (tester) async {
      await open(tester, which: 0);
      await weave(tester, 0, 1);
      expect(state(tester).play.weave, [(0, 1)]);
      expect(find.text('1 / 3'), findsOne);
    });

    testWidgets('arming and disarming weaves nothing', (tester) async {
      await open(tester, which: 0);
      await tapStrand(tester, 1);
      expect(state(tester).armed, 1);
      await tapStrand(tester, 1);
      expect(state(tester).armed, -1);
      expect(state(tester).play.placed, 0);
    });

    testWidgets('either order lands the same comb', (tester) async {
      await open(tester, which: 0);
      await weave(tester, 2, 0);
      expect(state(tester).play.weave, [(0, 2)]);
    });

    testWidgets('Back lifts the last comb out', (tester) async {
      await open(tester, which: 0);
      await weave(tester, 0, 1);
      await press(tester, 'Back');
      expect(state(tester).play.placed, 0);
    });

    testWidgets('Again empties the frame', (tester) async {
      await open(tester, which: 0);
      await weave(tester, 0, 1);
      await weave(tester, 1, 2);
      await press(tester, 'Again');
      expect(state(tester).play.placed, 0);
    });
  });

  group('the words under the frame', () {
    testWidgets('a wasted comb is called out the moment it lands',
        (tester) async {
      await open(tester, which: 0);
      await weave(tester, 0, 1);
      await weave(tester, 0, 1);
      expect(find.textContaining('wasted the frame'), findsOne);
    });

    testWidgets('running out of combs still foul is called out',
        (tester) async {
      await open(tester, which: 2);
      await weave(tester, 0, 1);
      await weave(tester, 2, 3);
      await weave(tester, 0, 2);
      await weave(tester, 1, 3);
      expect(state(tester).play.outOfCombs, isTrue);
      expect(find.textContaining('still run'), findsOne);
    });

    testWidgets('Show me ghosts a comb the search has followed',
        (tester) async {
      await open(tester, which: 0);
      await press(tester, 'Show me');
      expect(state(tester).ghost, isNotNull);
      expect(state(tester).hints, 1);
      expect(find.textContaining('stays in reach'), findsOne);
    });

    testWidgets('Why runs the foul grist down the weave in beads',
        (tester) async {
      await open(tester, which: 1);
      await weave(tester, 0, 1);
      await press(tester, 'Why');
      expect(state(tester).showFoul, isTrue);
      expect(find.textContaining('nought-one principle'), findsOne);
      expect(find.textContaining('running your weave'), findsOne);
    });

    testWidgets('the short weave says so as it opens, and Why holds two '
        'proofs', (tester) async {
      await open(tester, which: 2);
      expect(find.textContaining('No weave of 4 combs riddles'),
          findsOne);
      await press(tester, 'Show me');
      expect(state(tester).ghost, isNull);
      expect(find.textContaining('nothing to show'), findsOne);
      await press(tester, 'Why');
      expect(find.textContaining('1,296'), findsOne);
      expect(find.textContaining('share nothing'), findsOne);
    });
  });

  group('a riddle run clean', () {
    testWidgets('following the game riddles every winnable mesh',
        (tester) async {
      for (var number = 0; number < Meshes.count; number++) {
        final mesh = Meshes.at(number);
        if (!mesh.winnable) continue;
        await open(tester, which: number);
        await weaveItClean(tester);
        expect(state(tester).play.isClean, isTrue, reason: mesh.name);
        expect(state(tester).play.placed, mesh.combs, reason: mesh.name);
      }
    });

    testWidgets('the card runs the orderings through besides',
        (tester) async {
      await open(tester, which: 0);
      await weaveItClean(tester);
      expect(find.text('every grist runs clean'), findsOne);
      expect(find.textContaining('all 6 orderings ran it clean'),
          findsOne);
    });

    testWidgets('Next opens the mesh after', (tester) async {
      await open(tester, which: 0);
      await weaveItClean(tester);
      await press(tester, 'Next');
      expect(state(tester).play.mesh.name, Meshes.at(1).name);
    });
  });
}
