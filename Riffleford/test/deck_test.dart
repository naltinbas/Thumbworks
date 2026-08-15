import 'package:flutter_test/flutter_test.dart';
import 'package:riffleford/deck/play.dart';
import 'package:riffleford/deck/riffles.dart';
import 'package:riffleford/deck/rules.dart';

/// The law of the deck, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final riffle in Riffles.all) {
        final rules = Rules(riffle.deck, cut: riffle.cut, turned: riffle.turned, kinds: riffle.kinds);
        final (all, mixed) = rules.sweep();
        expect(all, riffle.riffles, reason: riffle.name);
        expect(riffle.wantMixed ? mixed : all - mixed, riffle.ways, reason: riffle.name);
        expect(rules.riffleCount(), all, reason: riffle.name);
      }
    });

    test('the piles read as cut and turned', () {
      final turned = Rules('RBRBRBRB', cut: 3, turned: true, kinds: 2);
      expect(turned.first, 'RBR');
      expect(turned.second, 'BRBRB');
      expect(turned.readOppositeWays(), isTrue);
      final even = Rules('RBRBRBRB', cut: 4, turned: true, kinds: 2);
      expect(even.first, 'BRBR');
      final flat = Rules('RBRBRBRB', cut: 4, turned: false, kinds: 2);
      expect(flat.first, 'RBRB');
      expect(flat.readOppositeWays(), isFalse);
    });

    test('dealing and blocks', () {
      final rules = Rules('RBRBRBRB', cut: 3, turned: true, kinds: 2);
      expect(rules.dealt('AAABBBBB'), 'RBRBRBRB');
      expect(rules.dealt('BBBBBAAA'), 'BRBRBRBR');
      expect(rules.dealt('ABBABABB'), 'RBRBBRRB');
      expect(rules.blocks('RBRBRB'), [true, true, true]);
      expect(rules.blocks('RRBB'), [false, false]);
      expect(rules.allMixed('AAABBBBB'), isTrue);
      final flat = Rules('RBRBRBRB', cut: 4, turned: false, kinds: 2);
      expect(flat.dealt('AABB'), 'RBRB');
      expect(flat.dealt('ABBA'), 'RRBB');
      expect(flat.blocks('RRBB'), [false, false]);
    });

    test('the tops-differ walk agrees with the sweep', () {
      expect(Rules('RBRBRBRB', cut: 3, turned: true, kinds: 2).topsDifferAlways(), isTrue);
      expect(Rules('RBRBRBRB', cut: 4, turned: true, kinds: 2).topsDifferAlways(), isTrue);
      expect(Rules('RBRBRBRB', cut: 4, turned: false, kinds: 2).topsDifferAlways(), isFalse);
      expect(Rules('RBRBRBRBRBRB', cut: 5, turned: true, kinds: 2).sweep(), (792, 792));
    });

    test('the unturned six deal the deck back as it was', () {
      final flat = Rules('RBRBRBRB', cut: 4, turned: false, kinds: 2);
      var six = 0;
      flat.riffles((drops) {
        if (flat.allMixed(drops)) {
          six++;
          expect(flat.dealt(drops), 'RBRBRBRB');
        }
      });
      expect(six, 6);
    });
  });

  group('the play', () {
    test('opens undropped', () {
      for (final riffle in Riffles.all) {
        final play = Play.of(riffle);
        expect(play.drops, isEmpty, reason: riffle.name);
        expect(play.isDone, isFalse);
        expect(play.leftA, riffle.cut);
      }
    });

    test('a drop takes a top card, counted every one, and back undoes', () {
      var play = Play.of(Riffles.at(0));
      play = play.drop('A');
      expect(play.drops, 'A');
      expect(play.dealt, 'R');
      expect(play.moves, 1);
      play = play.drop('B');
      expect(play.dealt, 'RB');
      expect(play.blocks, [true]);
      expect(play.back.drops, 'A');
      expect(play.drop('C'), same(play));
    });

    test('an empty pile drops nothing', () {
      var play = Play.of(Riffles.at(0));
      play = play.drop('A').drop('A').drop('A');
      expect(play.leftA, 0);
      expect(play.drop('A'), same(play));
    });

    test('the odd cut lands however it is riffled', () {
      final rules = Rules('RBRBRBRB', cut: 3, turned: true, kinds: 2);
      rules.riffles((drops) {
        var play = Play.of(Riffles.at(0));
        for (final d in drops.split('')) {
          play = play.drop(d);
        }
        expect(play.isDone, isTrue, reason: drops);
        expect(play.moves, 8);
      });
    });

    test('the unturned packet lands only alternating', () {
      // Both piles read R B R B, so two from one then two from the
      // other keeps the deck alternating; strict turns do not.
      final good = Play.of(Riffles.at(2)).drop('A').drop('A').drop('B').drop('B').drop('A').drop('A').drop('B').drop('B');
      expect(good.dealt, 'RBRBRBRB');
      expect(good.isDone, isTrue);
      final bad = Play.of(Riffles.at(2)).drop('A').drop('B').drop('A').drop('B').drop('A').drop('B').drop('A').drop('B');
      expect(bad.dealt, 'RRBBRRBB');
      expect(bad.full, isTrue);
      expect(bad.isDone, isFalse);
      expect(bad.blocks.first, isFalse);
    });

    test('the pointer deals the three kinds and the unturned packet', () {
      for (final number in [3, 2]) {
        var play = Play.of(Riffles.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 14) {
          play = play.drop(play.next!);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
    });

    test('the pointer minds the drops already made', () {
      final play = Play.of(Riffles.at(2)).drop('A');
      expect(play.next, 'A');
      // A red on a red: no riffle from here keeps every pair mixed.
      expect(Play.of(Riffles.at(2)).drop('A').drop('B').next, isNull);
    });

    test('the hopeless riffle admits it once the deck is dealt', () {
      var play = Play.of(Riffles.at(4));
      for (final d in 'AAABBBBB'.split('')) {
        play = play.drop(d);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.full, isTrue);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
      // Every full riffle of it cracks the same way.
      final rules = Rules('RBRBRBRB', cut: 3, turned: true, kinds: 2);
      rules.riffles((drops) {
        var run = Play.of(Riffles.at(4));
        for (final d in drops.split('')) {
          run = run.drop(d);
        }
        expect(run.gaveUp, isTrue, reason: drops);
      });
    });

    test('a winnable riffle never gives up, even dealt wrong', () {
      var play = Play.of(Riffles.at(2));
      for (final d in 'ABABABAB'.split('')) {
        play = play.drop(d);
      }
      expect(play.moves, 8);
      expect(play.full, isTrue);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands dealt', () {
      final mark = Play.standing(Riffles.at(0), 'ABBABABB');
      expect(mark.isDone, isTrue);
      expect(mark.dealt, 'RBRBBRRB');
    });
  });
}
