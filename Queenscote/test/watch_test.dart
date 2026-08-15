import 'package:flutter_test/flutter_test.dart';
import 'package:queenscote/watch/levels.dart';
import 'package:queenscote/watch/play.dart';
import 'package:queenscote/watch/rules.dart';

/// The queens, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the watch', () {
    test('what a queen sees', () {
      // On the four by four, the corner sees 10 and a middle square 12.
      var n = 0;
      for (var s = 0; s < 16; s++) {
        if (Rules.seenFrom(4, 0) & (1 << s) != 0) n++;
      }
      expect(n, 10);
      expect(Rules.mostSeen(4), (12, 5));
      expect(Rules.mostSeen(8), (28, 27));
      expect(Rules.unseen(4, [5]), 4);
      expect(Rules.unseen(4, [0, 10]), 0);
      expect(Rules.watches(4, [0, 10]), isTrue);
      expect(Rules.watches(4, [0, 1]), isFalse);
      expect(Rules.watches(8, [0, 1, 13, 32, 44]), isTrue);
      expect(Rules.unseen(8, [0, 12, 39, 57]), 2);
      expect(Rules.told(8, 0), 'a8');
      expect(Rules.told(8, 63), 'h1');
      expect(Rules.told(4, 5), 'b3');
    });

    test('the sweep and the picking agree on the small boards', () {
      for (final (side, q, count) in [(4, 1, 0), (4, 2, 12), (5, 3, 186), (6, 3, 4), (7, 4, 86)]) {
        expect(Rules.sweep(side, q).$1, count, reason: '$side by $side, $q');
        expect(Rules.picking(side, q).$1, count, reason: '$side by $side, $q');
      }
      expect(Rules.sweep(4, 1).$2, 4);
      expect(Rules.sweep(6, 2), (0, 6));
      expect(Rules.picking(4, 2).$2, [0, 10]);
      expect(Rules.picking(6, 3).$2, [0, 16, 26]);
      expect(Rules.sweepUnseen(4, 1, 4), 4);
    });

    test('the chessboard: four queens leave two unseen at best, and the first five', () {
      expect(Rules.sweep(8, 4), (0, 2));
      expect(Rules.sweepUnseen(8, 4, 2), 64);
      expect(Rules.picking(8, 5).$2, [0, 1, 13, 32, 44]);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Lone Queen']);
      for (final level in Levels.all) {
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set two queens on the four by four so every square is seen');
      expect(Levels.at(2).task, 'set five queens on the chessboard so every square is seen');
      expect(Levels.at(3).task, 'set four queens on the chessboard so exactly two squares are left unseen');
      expect(Levels.at(4).task, 'set one queen on the four by four so every square is seen');
    });

    test('an ask is met by the count of queens and what they leave', () {
      expect(Levels.at(0).meets([0, 10]), isTrue);
      expect(Levels.at(0).meets([0]), isFalse);
      expect(Levels.at(0).meets([0, 1]), isFalse);
      expect(Levels.at(3).meets([0, 12, 39, 57]), isTrue);
      expect(Levels.at(3).meets([0, 1, 13, 32]), isFalse);
      expect(Levels.at(4).meets([5]), isFalse);
    });
  });

  group('the play', () {
    test('opens bare', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.placed, isEmpty);
        expect(play.moves, 0);
        expect(play.unseen, level.squares);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap sets a queen, a second lifts her, and no more than asked', () {
      var play = Play.of(Levels.at(0)).tap(0);
      expect(play.placed, [0]);
      expect(play.moves, 1);
      expect(play.unseen, 6);
      play = play.tap(1);
      expect(play.isFull, isTrue);
      expect(play.tap(2), same(play));
      play = play.tap(1);
      expect(play.placed, [0]);
      expect(play.moves, 3);
      expect(play.tap(99), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(10);
      expect(play.back.placed, [0]);
      expect(play.back.back.placed, isEmpty);
    });

    test('the four by four lands, and it takes no more taps', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(10);
      expect(play.isDone, isTrue);
      expect(play.tap(0), same(play));
    });

    test('the pointer lifts strays and sets the aim', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (Aim.set, 0));
      play = play.tap(3);
      expect(play.next, (Aim.lift, 3));
      play = play.tap(3).tap(0).tap(16);
      expect(play.next, (Aim.set, 26));
      expect(Play.pointed((Aim.set, 26), 6), 'Set a queen at c2.');
      expect(Play.pointed((Aim.lift, 3), 6), 'Lift the queen at d6.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer watches every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          play = play.tap(play.next!.$2);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.queens, reason: level.name);
      }
    });

    test('the lone queen admits it on a middle square, or after twenty taps', () {
      var play = Play.of(Levels.at(4)).tap(0);
      expect(play.unseen, 6);
      expect(play.gaveUp, isFalse);
      play = play.tap(0).tap(5);
      expect(play.unseen, 4);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.tap(0);
      }
      expect((wander.moves, wander.gaveUp), (20, true));
    });

    test('the why tells the five and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('five watch it in 4,860 ways, and four never'));
      expect(words, contains('This is ask 5, The Lone Queen.'));
      expect(words, contains('tried in full'));
    });
  });
}
