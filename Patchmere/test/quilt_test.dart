import 'package:flutter_test/flutter_test.dart';
import 'package:patchmere/quilt/house.dart';
import 'package:patchmere/quilt/levels.dart';
import 'package:patchmere/quilt/play.dart';
import 'package:patchmere/quilt/rules.dart';

/// The law of the quilt, held to.
void main() {
  group('the rules', () {
    test('the places for a patch are counted two ways on every small quilt', () {
      for (var rows = 1; rows <= 5; rows++) {
        for (var cols = 1; cols <= 5; cols++) {
          final q = Quilt(rows, cols);
          expect(q.patches.length, q.patchesByArithmetic, reason: '$rows x $cols');
          expect(q.patches.toSet().length, q.patches.length);
        }
      }
      expect(Quilt(2, 6).patches, hasLength(16));
      expect(Quilt(4, 4).patches, hasLength(24));
      expect(Quilt(4, 5).patches, hasLength(31));
    });

    test('a patch is its own mirror only when one side is odd', () {
      expect(Quilt(2, 6).selfMirrored, isEmpty);
      expect(Quilt(4, 4).selfMirrored, isEmpty);
      expect(Quilt(3, 3).selfMirrored, isEmpty);
      expect(Quilt(3, 4).selfMirrored, [(5, 6)]);
      expect(Quilt(4, 5).selfMirrored, [(7, 12)]);
      expect(Quilt(3, 4).middle, (5, 6));
      expect(Quilt(2, 6).middle, isNull);
    });

    test('the mirror runs across the middle', () {
      final q = Quilt(2, 6);
      expect(q.mirror((0, 1)), (10, 11));
      expect(q.mirror((2, 8)), (3, 9));
      expect(q.mirror(q.mirror((4, 5))), (4, 5));
      final f = Quilt(4, 4);
      expect(f.mirror((0, 4)), (11, 15));
      expect(f.mirror((5, 6)), (9, 10));
    });

    test('the tree reads the small quilts as told', () {
      expect(Quilt(2, 2).moverWins(0), isFalse);
      expect(Quilt(2, 4).moverWins(0), isFalse);
      expect(Quilt(2, 6).moverWins(0), isFalse);
      expect(Quilt(4, 4).moverWins(0), isFalse);
      expect(Quilt(3, 3).moverWins(0), isFalse);
      expect(Quilt(2, 3).moverWins(0), isTrue);
      expect(Quilt(3, 4).moverWins(0), isTrue);
      expect(Quilt(3, 5).moverWins(0), isTrue);
      expect(Quilt(4, 5).moverWins(0), isTrue);
      expect(Quilt(3, 4).winningMoves(0), hasLength(7));
      expect(Quilt(3, 4).winningMoves(0), contains((5, 6)));
      expect(Quilt(4, 5).winningMoves(0), hasLength(5));
      expect(Quilt(4, 5).winningMoves(0), contains((7, 12)));
      expect(Quilt(3, 5).winningMoves(0), hasLength(8));
    });

    test('the mirror always fits and sews last on the four by four', () {
      final q = Quilt(4, 4);
      var games = 0;
      void walk(int sewn) {
        final moves = q.moves(sewn);
        expect(moves, isNotEmpty, reason: q.picture(sewn));
        for (final p in moves) {
          final after = q.sew(sewn, p);
          final back = q.mirror(p);
          expect(q.fits(after, back), isTrue, reason: '$p at ${q.picture(after)}');
          final answered = q.sew(after, back);
          if (q.moves(answered).isEmpty) {
            games++;
          } else {
            walk(answered);
          }
        }
      }

      walk(0);
      expect(games, 3648);
    });
  });

  group('the house', () {
    test('mirrors when second on an even quilt, takes the middle when first on an odd one', () {
      final four = Quilt(4, 4);
      expect(House.advise(four, four.sew(0, (0, 1)), houseFirst: false, yourLast: (0, 1)), ((14, 15), 'mirror'));
      final three = Quilt(3, 4);
      expect(House.advise(three, 0, houseFirst: true), ((5, 6), 'middle'));
      final six = Quilt(2, 6);
      expect(House.advise(six, 0, houseFirst: true).$2, 'any');
      expect(House.advise(three, three.sew(0, (0, 1)), houseFirst: false, yourLast: (0, 1)).$2, 'winning');
    });
  });

  group('the play', () {
    test('every label\'s ways is what the walk finds', () {
      for (final level in Levels.all) {
        var games = 0, won = 0;
        void walk(Play play) {
          if (play.isOver) {
            games++;
            if (play.won) won++;
            return;
          }
          for (final p in play.quilt.moves(play.sewn)) {
            walk(play.sewPatch(p));
          }
        }

        walk(Play.of(level));
        expect(games, level.games, reason: level.name);
        expect(won, level.ways, reason: level.name);
        expect(Play.of(level).youWin, level.winnable, reason: level.name);
      }
    });

    test('opens on the quilt, the house sewing first when it is its turn', () {
      final six = Play.of(Levels.at(0));
      expect(six.patches, [((0, 1), false)]);
      expect(six.houseRule, 'any');
      final four = Play.of(Levels.at(1));
      expect(four.patches, isEmpty);
      expect(four.houseLast, isNull);
    });

    test('two taps sew a patch and the house answers; a lone tap only picks', () {
      var play = Play.of(Levels.at(1));
      play = play.tap(0);
      expect(play.held, 0);
      expect(play.moves, 0);
      play = play.tap(0);
      expect(play.held, isNull);
      play = play.tap(0).tap(7);
      expect(play.held, 7);
      play = play.tap(6);
      expect(play.held, isNull);
      expect(play.moves, 1);
      expect(play.patches.first, ((6, 7), true));
      expect(play.patches, hasLength(2));
      expect(play.tap(6), same(play));
      expect(play.back.moves, 0);
    });

    test('mirroring the house sews last on the two by six', () {
      var play = Play.of(Levels.at(0));
      while (!play.isOver) {
        play = play.sewPatch(play.quilt.mirror(play.houseLast!));
      }
      expect(play.won, isTrue);
      expect(play.moves, 3);
      expect(play.patches, [
        ((0, 1), false),
        ((10, 11), true),
        ((2, 3), false),
        ((8, 9), true),
        ((4, 5), false),
        ((6, 7), true),
      ]);
    });

    test('the pointer lands every winnable level, and points at the mirror', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        while (!play.isOver) {
          final next = play.next!;
          if (play.houseLast != null && play.quilt.winningMoves(play.sewn).contains(play.quilt.mirror(play.houseLast!))) {
            expect(next, play.quilt.mirror(play.houseLast!), reason: '$number');
          }
          play = play.sewPatch(next);
        }
        expect(play.won, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the middle opens the three by four and the four by five', () {
      expect(Play.of(Levels.at(1)).next, (5, 6));
      expect(Play.of(Levels.at(3)).next, (7, 12));
    });

    test('the house sews last on the four by four whatever you sew', () {
      var play = Play.of(Levels.at(4));
      while (!play.isOver) {
        play = play.sewPatch(play.quilt.moves(play.sewn).first);
        if (!play.isOver || play.patches.length.isEven) expect(play.houseRule, 'mirror');
      }
      expect(play.lost, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.tap(0), same(play));
    });

    test('a wrong opening on the three by four is lost, and the house takes it', () {
      var play = Play.of(Levels.at(1)).sewPatch((0, 1));
      expect(play.youWin, isFalse);
      while (!play.isOver) {
        play = play.sewPatch(play.quilt.moves(play.sewn).first);
      }
      expect(play.lost, isTrue);
      expect(play.gaveUp, isFalse);
    });

    test('the mark is the two by six sewn out by mirrors', () {
      final q = Quilt(2, 6);
      var sewn = 0;
      for (var i = 0; i < 6; i += 2) {
        final (house, _) = mirroredMark[i];
        final (mine, _) = mirroredMark[i + 1];
        expect(mine, q.mirror(house));
        sewn = q.sew(q.sew(sewn, house), mine);
      }
      expect(q.moves(sewn), isEmpty);
    });
  });
}

const mirroredMark = [
  ((0, 1), false),
  ((10, 11), true),
  ((2, 3), false),
  ((8, 9), true),
  ((4, 5), false),
  ((6, 7), true),
];
