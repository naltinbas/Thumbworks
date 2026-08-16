import 'package:flutter_test/flutter_test.dart';
import 'package:ladderby/join/frac.dart';
import 'package:ladderby/join/levels.dart';
import 'package:ladderby/join/play.dart';
import 'package:ladderby/join/rules.dart';

/// The joins, the crossings, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the crossings', () {
    test('two joins cross exactly, by the general meeting and by the closed form', () {
      expect(Rules.tell(Rules.crossing(0, 1, 1, 0)!), '(1/2, 3)');
      expect(Rules.tell(Rules.crossingByForm(0, 1, 1, 0)!), '(1/2, 3)');
      expect(Rules.tell(Rules.crossing(0, 4, 2, 1)!), '(8/5, 12/5)');
      expect(Rules.crossing(0, 1, 1, 2), isNull);
      expect(Rules.crossingByForm(0, 1, 1, 2), isNull);
      final (x, y, z) = Rules.crossings([0, 1, 2], [0, 1, 2])!;
      expect([Rules.tell(x), Rules.tell(y), Rules.tell(z)], ['(1/2, 3)', '(1, 3)', '(3/2, 3)']);
      expect(Rules.crossingsByForm([0, 1, 2], [0, 1, 2]), (x, y, z));
      expect(Rules.inLine(x, y, z), isTrue);
      expect(Rules.inLine(x, y, (Frac.of(2), Frac.of(4))), isFalse);
      final (p, q, r) = Rules.crossings([0, 1, 2], [1, 2, 0])!;
      expect([Rules.tell(p), Rules.tell(q), Rules.tell(r)], ['(1, 3)', '(0, 12)', '(2, -6)']);
      expect(p.$1.isWhole && q.$2.isWhole && r.$2.isWhole, isTrue);
      expect(Rules.crossings([0, 1, 2], [2, 1, 0]), isNull);
      expect(Rules.crossings([0, 3, 6], [6, 3, 0]), isNull);
      expect(Rules.at((0, 4)), (Frac.of(4), Frac.zero));
      expect(Rules.at((1, 7)), (Frac.of(7), Frac.of(6)));
      expect(Rules.triples, hasLength(336));
      expect(Rules.hexagons, 112896);
    });

    test('the two voices agree on every hexagon, and the crossings lie in a line on every one', () {
      var crossing = 0;
      for (final bottom in Rules.triples) {
        for (final top in Rules.triples) {
          final c = Rules.crossings(bottom, top);
          final c2 = Rules.crossingsByForm(bottom, top);
          if (c == null) {
            expect(c2, isNull, reason: '$bottom $top');
            continue;
          }
          crossing++;
          expect(c2, c, reason: '$bottom $top');
          expect(Rules.inLine(c.$1, c.$2, c.$3), isTrue, reason: '$bottom $top');
        }
      }
      expect(crossing, 85008);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Bent Line']);
      for (final level in Levels.all) {
        final found = <String>{};
        for (final bottom in Rules.triples) {
          for (final top in Rules.triples) {
            if (level.meets(bottom, top)) found.add(([for (var i = 0; i < 3; i++) '${bottom[i]}-${top[i]}']..sort()).join(','));
          }
        }
        expect(found.length, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      // A record holding lists compares by identity, so field by field.
      final aims = [([0, 1, 2], [0, 1, 2]), ([0, 1, 2], [0, 1, 2]), ([0, 1, 2], [1, 2, 0]), ([0, 2, 3], [0, 6, 3])];
      for (var i = 0; i < 4; i++) {
        expect(Levels.at(i).aim!.$1, aims[i].$1, reason: Levels.at(i).name);
        expect(Levels.at(i).aim!.$2, aims[i].$2, reason: Levels.at(i).name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'pick the pegs so that the three crossings stand at one height');
      expect(Levels.at(1).task, 'pick the pegs so that the three crossings stand halfway between the rails');
      expect(Levels.at(2).task, 'pick the pegs so that the three crossings all fall on pegs');
      expect(Levels.at(3).task, 'pick the pegs so that the three crossings stand one above another');
      expect(Levels.at(4).task, 'pick the pegs so that the three crossings do not lie in a line');
    });

    test('an ask is met by the hexagon', () {
      expect(Levels.at(0).meets([0, 1, 2], [0, 2, 4]), isTrue);
      expect(Levels.at(1).meets([0, 1, 2], [0, 2, 4]), isFalse);
      expect(Levels.at(1).meets([1, 2, 3], [2, 3, 4]), isTrue);
      expect(Levels.at(0).meets([0, 2, 5], [1, 4, 6]), isFalse);
      expect(Levels.at(2).meets([0, 1, 2], [1, 2, 0]), isTrue);
      expect(Levels.at(2).meets([0, 1, 2], [0, 1, 2]), isFalse);
      expect(Levels.at(3).meets([0, 2, 3], [0, 6, 3]), isTrue);
      expect(Levels.at(3).meets([0, 1, 2], [0, 1, 2]), isFalse);
      expect(Levels.at(4).meets([0, 2, 5], [1, 4, 6]), isFalse);
      expect(Levels.at(0).meets([0, 1, 2], [2, 1, 0]), isFalse);
    });
  });

  group('the play', () {
    test('opens with no pegs picked', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.bottom, isEmpty);
        expect(play.top, isEmpty);
        expect((play.moves, play.whole, play.tried), (0, false, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('taps pick and lift pegs, three a rail at most, and a parallel pair is named', () {
      // On the hopeless ask nothing lands, so the pegs can come and go.
      var play = Play.of(Levels.at(4)).tap((0, 0)).tap((0, 1)).tap((0, 2));
      expect(play.bottom, [0, 1, 2]);
      expect(play.tap((0, 5)), same(play));
      expect(play.tap((0, 1)).bottom, [0, 2]);
      expect(play.tap((2, 1)), same(play));
      expect(play.tap((1, 8)), same(play));
      play = play.tap((1, 2)).tap((1, 1)).tap((1, 0));
      expect(play.top, [2, 1, 0]);
      expect(play.whole, isTrue);
      expect(play.crossings, isNull);
      expect(play.parallel, 'A-b with a-B');
      expect(play.tried, 0);
      expect(play.moves, 6);
      expect(Play.of(Levels.at(4)).tap((0, 0)).tap((0, 1)).tap((0, 2)).tap((1, 0)).tap((1, 2)).tap((1, 1)).parallel, 'B-c with b-C');
      final crossed = Play.of(Levels.at(4)).tap((0, 0)).tap((0, 1)).tap((0, 2)).tap((1, 0)).tap((1, 1)).tap((1, 2));
      expect(crossed.parallel, isNull);
      expect(crossed.tried, 1);
      expect(crossed.inLine, isTrue);
      expect(crossed.crossingsByForm, crossed.crossings);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap((0, 3)).tap((1, 5));
      expect(play.back.top, isEmpty);
      expect(play.back.bottom, [3]);
      expect(play.back.back.bottom, isEmpty);
    });

    test('the pointer picks the aim in order, bottom rail first, and lifts a stray peg', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, ((0, 0), false));
      expect(Play.pointed(((0, 0), false)), 'Set peg 0 on the bottom rail.');
      play = play.tap((0, 5));
      expect(play.next, ((0, 5), true));
      expect(Play.pointed(((0, 5), true)), 'Lift peg 5 on the bottom rail.');
      play = play.tap((0, 5)).tap((0, 0)).tap((0, 1)).tap((0, 2)).tap((1, 4));
      expect(play.next, ((1, 4), true));
      expect(Play.pointed(((1, 4), true)), 'Lift peg 4 on the top rail.');
      expect(play.tap((1, 4)).next, ((1, 0), false));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask in six taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 12) {
          final (peg, _) = play.next!;
          play = play.tap(peg);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, 6, reason: level.name);
      }
    });

    test('the bent line admits it after three hexagons, or eighteen taps', () {
      var play = Play.of(Levels.at(4)).tap((0, 0)).tap((0, 1)).tap((0, 2)).tap((1, 0)).tap((1, 1)).tap((1, 2));
      expect(play.tried, 1);
      expect(play.gaveUp, isFalse);
      play = play.tap((1, 2)).tap((1, 3));
      expect(play.tried, 2);
      expect(play.gaveUp, isFalse);
      play = play.tap((1, 3)).tap((1, 4));
      expect(play.tried, 3);
      expect(play.gaveUp, isTrue);
      expect(play.moves, 10);
      expect(play.next, isNull);
      final (x, y, z) = play.crossings!;
      expect([Rules.tell(x), Rules.tell(y), Rules.tell(z)], ['(1/2, 3)', '(4/3, 2)', '(7/4, 3/2)']);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 18; k++) {
        wander = wander.tap((0, 3));
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Pappus and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Pappus of Alexandria'));
      expect(words, contains('85,008 orderings'));
      expect(words, contains('This is ask 5, The Bent Line.'));
      expect(words, contains('crossed in full'));
    });
  });
}
