import 'package:flutter_test/flutter_test.dart';
import 'package:goatsbridge/stall/levels.dart';
import 'package:goatsbridge/stall/play.dart';
import 'package:goatsbridge/stall/rules.dart';

/// The formula, the count of cases and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the chances', () {
    test('by the formula', () {
      expect(Rules.byFormula(3, 1, false), (1, 3));
      expect(Rules.byFormula(3, 1, true), (2, 3));
      expect(Rules.byFormula(4, 1, true), (3, 8));
      expect(Rules.byFormula(4, 2, true), (3, 4));
      expect(Rules.byFormula(10, 8, true), (9, 10));
      expect(Rules.byFormula(10, 1, true), (9, 80));
      expect(Rules.byFormula(10, 1, false), (1, 10));
    });

    test('by counting every case, the same', () {
      for (final (n, k) in [(3, 1), (4, 1), (4, 2), (5, 2), (6, 1), (7, 5)]) {
        for (final sw in [false, true]) {
          expect(Rules.byCases(n, k, sw), Rules.byFormula(n, k, sw), reason: '$n $k $sw');
        }
      }
    });

    test('in a hundred, and compared', () {
      expect(Rules.inHundred((2, 3)), '66.66');
      expect(Rules.inHundred((9, 80)), '11.25');
      expect(Rules.compare((2, 3), (1, 2)), 1);
      expect(Rules.compare((1, 3), (2, 6)), 0);
      expect(Rules.compare((9, 80), (1, 10)), 1);
    });
  });

  group('the sweep', () {
    test('72 settings, and the counts', () {
      expect(Rules.sweep((n, k, sw) => true), (72, 72));
      expect(Rules.sweep(Levels.at(0).meets), (1, 72));
      expect(Rules.sweep(Levels.at(1).meets), (1, 72));
      expect(Rules.sweep(Levels.at(2).meets), (8, 72));
      expect(Rules.sweep(Levels.at(3).meets), (1, 72));
      expect(Rules.sweep(Levels.at(4).meets), (0, 72));
    });

    test('staying never wins as many as switching', () {
      expect(Rules.sweep((n, k, sw) => Rules.compare(Rules.byFormula(n, k, false), Rules.byFormula(n, k, true)) >= 0), (0, 72));
    });

    test('the first settings', () {
      expect(Rules.first(Levels.at(0).meets), (3, 1, true));
      expect(Rules.first(Levels.at(1).meets), (4, 2, true));
      expect(Rules.first(Levels.at(2).meets), (3, 1, true));
      expect(Rules.first(Levels.at(3).meets), (10, 1, true));
      expect(Rules.first(Levels.at(4).meets), isNull);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Stay']);
      expect(Levels.at(0).settings, 72);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the stall so the policy wins two in three exactly');
      expect(Levels.at(2).task, 'set the stall so the policy wins more than half the games');
      expect(Levels.at(3).task, 'set the stall where switching wins the least it ever does on the sham');
      expect(Levels.at(4).task, 'set the stall so that staying wins more games than switching');
    });

    test('an ask is met by the setting it names', () {
      expect(Levels.at(0).meets(3, 1, true), isTrue);
      expect(Levels.at(0).meets(3, 1, false), isFalse);
      expect(Levels.at(2).meets(5, 3, true), isTrue);
      expect(Levels.at(2).meets(5, 2, true), isFalse);
      expect(Levels.at(3).meets(10, 1, true), isTrue);
      expect(Levels.at(3).meets(9, 1, true), isFalse);
      expect(Levels.at(4).meets(3, 1, false), isFalse);
    });
  });

  group('the play', () {
    test('opens on three doors, one opened, staying', () {
      final play = Play.of(Levels.at(0));
      expect((play.doors, play.opened, play.switching), (3, 1, false));
      expect(play.chance, (1, 3));
      expect(play.isDone, isFalse);
    });

    test('doors and openings turn within their bounds, and the policy toggles', () {
      var play = Play.of(Levels.at(1));
      play = play.moreDoors(1);
      expect(play.doors, 4);
      play = play.moreOpened(1);
      expect(play.opened, 2);
      play = play.moreOpened(1);
      expect(play.opened, 2);
      expect(play.moves, 2);
      play = play.moreDoors(-1);
      // Back to three doors, the openings kept within one.
      expect((play.doors, play.opened), (3, 1));
      play = play.moreDoors(-1);
      expect(play.doors, 3);
      play = play.togglePolicy();
      expect(play.switching, isTrue);
      expect(play.moves, 4);
    });

    test('back undoes one setting', () {
      final play = Play.of(Levels.at(0)).togglePolicy();
      expect(play.back.switching, isFalse);
    });

    test('three in four lands by hand', () {
      final play = Play.of(Levels.at(1)).moreDoors(1).moreOpened(1).togglePolicy();
      expect(play.isDone, isTrue);
      expect(play.chance, (3, 4));
      expect(play.moves, 3);
    });

    test('the stay gives up after twenty-four settings', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        expect(play.isOver, isFalse);
        play = k.isEven ? play.moreDoors(1) : play.moreDoors(-1);
      }
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer names the dial toward the first setting', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, 'doors+');
      for (var i = 0; i < 7; i++) {
        play = play.moreDoors(1);
      }
      expect(play.doors, 10);
      expect(play.next, 'policy');
      play = play.togglePolicy();
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var presses = 0;
        while (!play.isDone && presses < 40) {
          play = switch (play.next!) {
            'doors+' => play.moreDoors(1),
            'doors-' => play.moreDoors(-1),
            'opened+' => play.moreOpened(1),
            'opened-' => play.moreOpened(-1),
            _ => play.togglePolicy(),
          };
          presses++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
