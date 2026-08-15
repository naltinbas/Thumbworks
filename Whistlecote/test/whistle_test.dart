import 'package:flutter_test/flutter_test.dart';
import 'package:whistlecote/whistle/level.dart';
import 'package:whistlecote/whistle/levels.dart';
import 'package:whistlecote/whistle/play.dart';
import 'package:whistlecote/whistle/rules.dart';

/// The law of the whistles, held to.
void main() {
  const rules = Level.rules;

  group('the rules', () {
    test('nodes are whistles, low left and high right', () {
      expect(Rules.notesOf(2), 1);
      expect(Rules.notesOf(15), 3);
      expect(Rules.notes(6), [true, false]);
      expect(Rules.said(6), 'high, low');
      expect(Rules.said(13), 'high, low, high');
      expect(rules.nodes, hasLength(14));
      expect(rules.whole, 8);
    });

    test('one whistle starts another down the tree', () {
      expect(Rules.begins(2, 4), isTrue);
      expect(Rules.begins(2, 11), isTrue);
      expect(Rules.begins(2, 12), isFalse);
      expect(Rules.begins(4, 2), isFalse);
      expect(Rules.begins(6, 6), isFalse);
      expect(rules.clashes([2, 6, 14, 15, 12]), [(6, 12)]);
      expect(rules.prefixFree([2, 6, 7]), isTrue);
      expect(rules.shadowed(5, [2]), isTrue);
      expect(rules.shadowed(6, [2]), isFalse);
    });

    test('shares, landing, the sweep and the product', () {
      expect(rules.share([1, 2, 2]), 8);
      expect(rules.share([1, 2, 3, 3, 3]), 9);
      expect(rules.fits([1, 2, 3, 3, 3]), isFalse);
      expect(rules.lands([2, 6, 7], [1, 2, 2]), isTrue);
      expect(rules.lands([2, 4, 5], [1, 2, 2]), isFalse);
      expect(rules.lands([2, 6], [1, 2, 2]), isFalse);
      expect(rules.sweep([1, 2, 2]), (2, 12));
      expect(rules.product([1, 2, 2]), 2);
      expect(Rules.choose(8, 4), 70);
      expect(Rules.choose(2, 3), 0);
    });

    test('the shepherd\'s way, or nothing', () {
      expect(rules.byShepherd([1, 2, 2]), [2, 6, 7]);
      expect(rules.byShepherd([2, 2, 3, 3]), [4, 5, 12, 13]);
      expect(rules.byShepherd([1, 2, 3, 3, 3]), isNull);
    });

    test('every set of up to five calls of up to three notes: sweep, shares, shepherd and product agree', () {
      var sets = 0;
      for (var m1 = 0; m1 <= 5; m1++) {
        for (var m2 = 0; m1 + m2 <= 5; m2++) {
          for (var m3 = 1 - m1 - m2 > 0 ? 1 - m1 - m2 : 0; m1 + m2 + m3 <= 5; m3++) {
            final lengths = [...List.filled(m1, 1), ...List.filled(m2, 2), ...List.filled(m3, 3)];
            sets++;
            final (landing, _) = rules.sweep(lengths);
            expect(landing > 0, rules.fits(lengths), reason: '$lengths');
            expect(rules.product(lengths), landing, reason: '$lengths');
            final shepherd = rules.byShepherd(lengths);
            expect(shepherd != null, landing > 0, reason: '$lengths');
            if (shepherd != null) expect(rules.lands(shepherd, lengths), isTrue, reason: '$lengths');
          }
        }
      }
      expect(sets, 55);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(rules.sweep(level.lengths), (level.ways, level.markings), reason: level.name);
        expect(rules.fits(level.lengths), level.winnable, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with nothing whistled', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.marks, isEmpty, reason: level.name);
        expect(play.isDone, isFalse);
        expect(play.share, 0);
      }
    });

    test('a tap marks, a tap lifts, counted both ways; back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(2);
      expect(play.marks, [2]);
      expect(play.callOf(2), 0);
      play = play.tap(2);
      expect(play.marks, isEmpty);
      expect(play.moves, 2);
      expect(play.back.marks, [2]);
      expect(play.tap(1), same(play));
      expect(play.tap(16), same(play));
    });

    test('the calls take whistles in tap order, and one over is nobody\'s', () {
      final play = Play.of(Levels.at(0)).tap(7).tap(6).tap(4);
      expect(play.callOf(7), 1);
      expect(play.callOf(6), 2);
      expect(play.callOf(4), isNull);
      expect(play.nodeOf(1), 7);
      expect(play.whistled, 2);
      expect(play.over, 1);
      expect(play.share, 6);
    });

    test('the sets by hand', () {
      final three = Play.of(Levels.at(0)).tap(2).tap(6).tap(7);
      expect(three.isDone, isTrue);
      expect(three.share, 8);
      expect(three.tap(4), same(three));
      final clash = Play.of(Levels.at(0)).tap(2).tap(4);
      expect(clash.clashes, [(2, 4)]);
      expect(clash.shadowed(9), isTrue);
      final four = Play.of(Levels.at(1)).tap(3).tap(4).tap(10).tap(11);
      expect(four.isDone, isTrue);
    });

    test('the pointer whistles every winnable set', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 30) {
          final (_, k) = play.next!;
          play = play.tap(k);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says mark or lift', () {
      final play = Play.of(Levels.at(0));
      expect(play.next, ('mark', 2));
      expect(play.tap(2).next, ('mark', 6));
      expect(play.tap(3).next, ('lift', 3));
    });

    test('the hopeless set admits it at thirteen taps', () {
      var play = Play.of(Levels.at(4)).tap(2).tap(6).tap(14).tap(15).tap(12);
      expect(play.clashes, [(6, 12)]);
      expect(play.share, 9);
      for (final k in [12, 13, 13, 12, 12, 13, 13, 12]) {
        play = play.tap(k);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.clashes, [(6, 12)]);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(2), same(play));
    });

    test('a winnable set never gives up', () {
      var play = Play.of(Levels.at(0));
      for (var k = 0; k < 14; k++) {
        play = play.tap(3);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands whistled', () {
      final mark = Play.standing(Levels.at(1), Play.aimFor(Levels.at(1))!);
      expect(mark.isDone, isTrue);
      expect(mark.share, 8);
    });
  });
}
