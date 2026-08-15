import 'package:flutter_test/flutter_test.dart';
import 'package:cellarwick/glass/levels.dart';
import 'package:cellarwick/glass/play.dart';
import 'package:cellarwick/glass/rules.dart';

/// The pourings, the account, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the pourings', () {
    test('well stirred, afloat and sunk, and the account holds', () {
      expect(Rules.stirred(10, 10, 1), (Frac.of(10, 11), Frac.of(10, 11)));
      expect(Rules.stirred(2, 2, 2), (Frac.one, Frac.one));
      expect(Rules.stirred(10, 4, 4), (Frac.of(2), Frac.of(2)));
      expect(Rules.stirred(1, 5, 2), isNull);
      expect(Rules.floating(10, 10, 1), (Frac.zero, Frac.zero));
      expect(Rules.sunk(10, 10, 1), (Frac.one, Frac.one));
      expect(Rules.sunk(10, 1, 3), (Frac.one, Frac.one));
      expect(Rules.pours(3, 5, 4), isFalse);
      var pourings = 0;
      for (var w = 1; w <= 10; w++) {
        for (var v = 1; v <= 10; v++) {
          for (var s = 1; s <= 5; s++) {
            for (final p in [Rules.stirred(w, v, s), Rules.floating(w, v, s), Rules.sunk(w, v, s)]) {
              if (p == null) continue;
              pourings++;
              expect(Rules.accountHolds(p), isTrue, reason: '$w $v $s');
            }
          }
        }
      }
      expect(pourings, 1200);
      expect(Rules.settings, 500);
    });

    test('the sweep', () {
      expect(Rules.sweep((w, v, s) => Rules.stirred(w, v, s)?.$1 == Frac.one), (9, 500, (2, 2, 2)));
      expect(Rules.sweep((w, v, s) {
        final p = Rules.stirred(w, v, s);
        return p != null && p.$1 != p.$2;
      }), (0, 500, null));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Unequal']);
      for (final level in Levels.all) {
        final (met, all, _) = Rules.sweep(level.meets);
        expect((met, all), (level.ways, 500), reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2, aim.$3), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the glasses and the spoon so exactly one unit of water ends in the wine glass');
      expect(Levels.at(3).task, 'set the glasses and the spoon so the water glass ends half wine');
      expect(Levels.at(4).task, 'set the glasses and the spoon so more water ends in the wine glass than wine in the water glass');
    });

    test('an ask is met by the pouring', () {
      expect(Levels.at(0).meets(7, 2, 2), isTrue);
      expect(Levels.at(0).meets(1, 2, 2), isFalse);
      expect(Levels.at(1).meets(5, 1, 1), isTrue);
      expect(Levels.at(1).meets(10, 10, 1), isFalse);
      expect(Levels.at(2).meets(10, 6, 3), isTrue);
      expect(Levels.at(2).meets(10, 10, 1), isFalse);
      expect(Levels.at(3).meets(9, 3, 3), isTrue);
      expect(Levels.at(3).meets(9, 3, 2), isFalse);
      expect(Levels.at(4).meets(10, 1, 5), isFalse);
    });
  });

  group('the play', () {
    test('opens on ten, ten and a spoon of one, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.dials, [10, 10, 1]);
        expect(play.pouring, (Frac.of(10, 11), Frac.of(10, 11)));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap turns a dial a step, and a dial at its end stays', () {
      var play = Play.of(Levels.at(0)).set(2, 1);
      expect(play.dials, [10, 10, 2]);
      expect(play.moves, 1);
      expect(play.set(0, 1), same(play));
      final top = Play.standing(Levels.at(0), 10, 10, 5);
      expect(top.set(2, 1), same(top));
      final low = Play.standing(Levels.at(0), 1, 1, 1);
      expect(low.set(1, -1), same(low));
      expect(low.set(2, 1).pours, isFalse);
      expect(low.set(2, 1).pouring, isNull);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(0, -1).set(1, -1);
      expect(play.back.dials, [9, 10, 1]);
      expect(play.back.back.dials, [10, 10, 1]);
    });

    test('the pointer walks dial by dial to the aim, and lands every winnable ask', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (0, -1));
      for (final level in Levels.all.where((l) => l.winnable)) {
        var p = Play.of(level);
        var steps = 0;
        while (!p.isDone && steps < 40) {
          p = p.set(p.next!.$1, p.next!.$2);
          steps++;
        }
        expect(p.isDone, isTrue, reason: level.name);
      }
      expect(Play.pointed((0, -1)), 'Less wine.');
      expect(Play.pointed((2, 1)), 'More in the spoon.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the unequal admits it at the wildest pouring, or after thirty taps', () {
      var play = Play.standing(Levels.at(4), 10, 2, 5);
      expect(play.gaveUp, isFalse);
      play = play.set(1, -1);
      expect(play.dials, [10, 1, 5]);
      expect(play.gaveUp, isTrue);
      expect(play.pouring, (Frac.of(5, 6), Frac.of(5, 6)));
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        wander = wander.set(0, k.isEven ? -1 : 1);
      }
      expect((wander.moves, wander.gaveUp), (30, true));
    });

    test('the why tells the account and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('fills exactly the room the missing wine left'));
      expect(words, contains('This is ask 5, The Unequal.'));
      expect(words, contains('tried in full'));
    });
  });
}
