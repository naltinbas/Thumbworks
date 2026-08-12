import 'package:addlemoor/sum/moors.dart';
import 'package:addlemoor/sum/play.dart';
import 'package:addlemoor/sum/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The law of the moor, held to.
void main() {
  group('the rules', () {
    test('bad sums allow a stone doubled', () {
      // 1 + 1 = 2 in one paint is a bad sum.
      expect(Rules.badSums([0, 0, 1]), [(1, 1, 2)]);
      expect(Rules.badSums([0, 1, 0]), isEmpty);
      // 1 + 2 = 3 all madder.
      expect(Rules.badSums([0, 0, 0]),
          containsAll([(1, 1, 2), (1, 2, 3)]));
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final moor in Moors.all) {
        expect(Rules(moor.stones, moor.paints).ways(), moor.ways,
            reason: moor.name);
      }
    });

    test('the walls stand where Schur left them', () {
      expect(Rules(4, 2).ways(), 2);
      expect(Rules(5, 2).ways(), 0);
      expect(Rules(13, 3).ways(), 18);
      expect(Rules(14, 3).ways(), 0);
    });

    test('the two fours are each other\'s swap', () {
      final fours = <List<int>>[];
      Rules(4, 2).paintings((painting) {
        fours.add(List.of(painting));
      });
      expect(fours, hasLength(2));
      expect(fours.first.map((paint) => 1 - paint).toList(),
          fours.last);
    });

    test('no clean thirteen takes a fourteenth stone', () {
      var extended = 0;
      Rules(13, 3).paintings((painting) {
        for (var paint = 0; paint < 3; paint++) {
          if (Rules.badSums([...painting, paint]).isEmpty) {
            extended++;
          }
        }
      });
      expect(extended, 0);
    });
  });

  group('the play', () {
    test('the moor opens all madder, sums showing, unlanded', () {
      final play = Play.of(Moors.at(0));
      expect(play.painting, everyElement(0));
      expect(play.badSums, isNotEmpty);
      expect(play.isDone, isFalse);
    });

    test('taps cycle a stone round the paints', () {
      var play = Play.of(Moors.at(1));
      play = play.tapAt(3);
      expect(play.painting[2], 1);
      expect(play.moves, 1);
      play = play.tapAt(3).tapAt(3);
      expect(play.painting[2], 0);
      expect(play.moves, 3);
    });

    test('a clean four lands', () {
      var play = Play.of(Moors.at(0));
      // 1 and 4 madder, 2 and 3 the other paint.
      play = play.tapAt(2).tapAt(3);
      expect(play.painting, [0, 1, 1, 0]);
      expect(play.badSums, isEmpty);
      expect(play.isDone, isTrue);
      expect(play.tapAt(1), same(play));
    });

    test('back takes back a repainting', () {
      var play = Play.of(Moors.at(0)).tapAt(2);
      expect(play.back.painting, everyElement(0));
      expect(play.back.moves, 0);
      expect(Play.of(Moors.at(0)).back.moves, 0);
    });

    test('show me paints the row home', () {
      var play = Play.of(Moors.at(1));
      var guard = 0;
      while (!play.isDone && guard++ < 30) {
        final aim = play.next;
        expect(aim, isNotNull);
        final (stone, paint) = aim!;
        while (play.painting[stone - 1] != paint) {
          play = play.tapAt(stone);
        }
      }
      expect(play.isDone, isTrue);
    });

    test('the hopeless moor has nothing to point at', () {
      expect(Play.of(Moors.at(4)).next, isNull);
    });

    test('the hopeless moor admits it after twelve repaintings', () {
      var play = Play.of(Moors.at(4));
      for (var repaint = 0; repaint < Play.gaveUpAt; repaint++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(1 + repaint % 14);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable moor never gives up', () {
      var play = Play.of(Moors.at(1));
      for (var repaint = 0; repaint < Play.gaveUpAt; repaint++) {
        play = play.tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
