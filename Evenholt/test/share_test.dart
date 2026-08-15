import 'package:flutter_test/flutter_test.dart';
import 'package:evenholt/share/play.dart';
import 'package:evenholt/share/rules.dart';
import 'package:evenholt/share/shares.dart';

/// The law of the share, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final share in Shares.all) {
        expect(
          Rules(share.count, share.degrees).waysBySweep(),
          share.ways,
          reason: share.name,
        );
      }
    });

    test('the powers narrow the shares, count by count', () {
      expect(Rules(4, 1).waysBySweep(), 1);
      expect(Rules(4, 2).waysBySweep(), 0);
      expect(Rules(8, 1).waysBySweep(), 4);
      expect(Rules(8, 2).waysBySweep(), 1);
      expect(Rules(8, 3).waysBySweep(), 0);
      expect(Rules(12, 1).waysBySweep(), 29);
      expect(Rules(12, 2).waysBySweep(), 1);
      expect(Rules(16, 1).waysBySweep(), 263);
      expect(Rules(16, 2).waysBySweep(), 7);
      expect(Rules(16, 3).waysBySweep(), 1);
    });

    test('Prouhet\'s pattern is the sweep\'s one share', () {
      for (final (count, degrees) in [(4, 1), (8, 2), (16, 3)]) {
        final rules = Rules(count, degrees);
        expect(rules.prouhet(), rules.landing(), reason: '$count');
        expect(rules.lands(rules.prouhet()!), isTrue);
        expect(Rules(count, degrees + 1).lands(rules.prouhet()!), isFalse);
      }
      expect(Rules(12, 2).prouhet(), isNull);
    });

    test('the eight and the sixteen read as Prouhet wrote them', () {
      final eight = Rules(8, 2).prouhet()!;
      expect(
        [for (var t = 1; t <= 8; t++) if (!eight[t - 1]) t],
        [1, 4, 6, 7],
      );
      final sixteen = Rules(16, 3).prouhet()!;
      expect(
        [for (var t = 1; t <= 16; t++) if (!sixteen[t - 1]) t],
        [1, 4, 6, 7, 10, 11, 13, 16],
      );
    });

    test('the polynomial carries the pattern and its root', () {
      for (final count in [4, 8, 16]) {
        final rules = Rules(count, 1);
        final poly = rules.prouhetPolynomial();
        final pattern = rules.prouhet()!;
        expect(poly, hasLength(count));
        for (var t = 1; t <= count; t++) {
          expect(poly[t - 1], pattern[t - 1] ? -1 : 1);
        }
        expect(Rules.rootAtOne(poly), rules.doublings);
      }
      expect(Rules(8, 1).prouhetPolynomial(),
          [1, -1, -1, 1, -1, 1, 1, -1]);
      expect(Rules.rootAtOne([1, -2, 1]), 2);
      expect(Rules.rootAtOne([1, 1]), 0);
    });

    test('the dozen shares once, with no doubling', () {
      final share = Rules(12, 2).landing()!;
      expect(
        [for (var t = 1; t <= 12; t++) if (!share[t - 1]) t],
        [1, 3, 7, 8, 9, 11],
      );
    });

    test('power sums add up as told', () {
      final rules = Rules(8, 2);
      final right = [false, true, true, false, true, false, false, true];
      expect(rules.powerSum(right, side: false, degree: 1), 18);
      expect(rules.powerSum(right, side: true, degree: 1), 18);
      expect(rules.powerSum(right, side: false, degree: 2), 102);
      expect(rules.powerSum(right, side: true, degree: 3), 672);
      expect(rules.agreeing(right), [true, true]);
      expect(rules.lands(right), isTrue);
    });
  });

  group('the play', () {
    test('opens with every token on the left', () {
      for (final share in Shares.all) {
        final play = Play.of(share);
        expect(play.leftTray, hasLength(share.count), reason: share.name);
        expect(play.rightTray, isEmpty);
        expect(play.isDone, isFalse, reason: share.name);
      }
    });

    test('a tap carries a token across and back, counted both ways', () {
      var play = Play.of(Shares.at(0));
      play = play.tap(3);
      expect(play.rightTray, [3]);
      expect(play.moves, 1);
      play = play.tap(3);
      expect(play.rightTray, isEmpty);
      expect(play.moves, 2);
      expect(play.back.rightTray, [3]);
      expect(play.tap(0), same(play));
      expect(play.tap(5), same(play));
    });

    test('the four shares by hand', () {
      final play = Play.of(Shares.at(0)).tap(2).tap(3);
      expect(play.leftTray, [1, 4]);
      expect(play.isDone, isTrue);
      expect(play.moves, 2);
      expect(play.tap(1), same(play));
    });

    test('the pointer deals the sixteen', () {
      var play = Play.of(Shares.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 20) {
        play = play.tap(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 8);
      expect(play.rightTray, [2, 3, 5, 8, 9, 12, 14, 15]);
    });

    test('the pointer honours the tray token 1 sits on', () {
      final play = Play.of(Shares.at(1)).tap(1);
      // Token 1 has gone right, so the aim is mirrored: 2 stays.
      final aim = <int>[];
      var walk = play;
      var guard = 0;
      while (!walk.isDone && guard++ < 20) {
        aim.add(walk.next!);
        walk = walk.tap(walk.next!);
      }
      expect(walk.isDone, isTrue);
      expect(walk.rightTray, [1, 4, 6, 7]);
      expect(aim, [4, 6, 7]);
    });

    test('the hopeless share admits it at eight moves', () {
      var play = Play.of(Shares.at(4)).tap(2).tap(3);
      expect(play.agreeing, [true, false]);
      for (var dither = 0; dither < 3; dither++) {
        play = play.tap(1).tap(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.leftTray, [1, 4]);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable share never gives up', () {
      var play = Play.of(Shares.at(1));
      for (var dither = 0; dither < 5; dither++) {
        play = play.tap(1).tap(1);
      }
      expect(play.moves, 10);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands shared', () {
      final mark = Play.standing(Shares.at(1), Rules(8, 2).prouhet()!);
      expect(mark.isDone, isTrue);
      expect(mark.leftTray, [1, 4, 6, 7]);
    });
  });
}
