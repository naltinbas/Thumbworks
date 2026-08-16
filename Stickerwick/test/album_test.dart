import 'package:flutter_test/flutter_test.dart';
import 'package:stickerwick/album/levels.dart';
import 'package:stickerwick/album/play.dart';
import 'package:stickerwick/album/rules.dart';

/// The averages, the chances, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the album', () {
    test('the average by the stages and by the tail', () {
      expect(Rules.averageByStages(6), Frac.of(147, 10));
      expect(Rules.averageByStages(1), Frac.one);
      expect(Rules.averageByStages(2), Frac.of(3));
      for (var n = 1; n <= 12; n++) {
        expect(Rules.averageByTail(n), Rules.averageByStages(n), reason: '$n');
      }
      expect(Rules.decimal(Rules.averageByStages(12)), '37.23');
      expect(Rules.choose(6, 2), BigInt.from(15));
    });

    test('the chance of a full album, by counting and by the walk', () {
      expect(Rules.fullAfter(1, 1), Frac.one);
      expect(Rules.fullAfter(2, 1), Frac.zero);
      expect(Rules.fullAfter(2, 2), Frac.of(1, 2));
      expect(Rules.fullAfter(2, 3), Frac.of(3, 4));
      for (var n = 1; n <= 8; n++) {
        for (var m = 1; m <= 30; m++) {
          expect(Rules.fullAfterByWalk(n, m), Rules.fullAfter(n, m), reason: '$n after $m');
        }
      }
      expect(Rules.decimal(Rules.fullAfter(6, 13)), '0.51');
      expect(Rules.decimal(Rules.fullAfter(6, 12)), '0.43');
      expect(Rules.median(6), 13);
      expect(Rules.median(12), 35);
      expect(Rules.fullAfter(6, 60).compareTo(Frac.one), lessThan(0));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Certain Album']);
      for (final level in Levels.all) {
        var met = 0;
        for (var n = 1; n <= 12; n++) {
          for (var m = 1; m <= 60; m++) {
            if (level.meets(n, m)) met++;
          }
        }
        expect(met, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set six stickers and the fewest packets that make the album more likely full than not');
      expect(Levels.at(2).task, 'set the stickers so the average packets to fill the album is a whole number');
      expect(Levels.at(4).task, 'set the stickers, two or more, and packets enough to make the album certain to be full');
    });

    test('an ask is met by the set and the packets', () {
      expect(Levels.at(0).meets(6, 13), isTrue);
      expect(Levels.at(0).meets(6, 14), isFalse);
      expect(Levels.at(0).meets(6, 12), isFalse);
      expect(Levels.at(1).meets(12, 35), isTrue);
      expect(Levels.at(1).meets(12, 34), isFalse);
      expect(Levels.at(2).meets(2, 7), isTrue);
      expect(Levels.at(2).meets(3, 7), isFalse);
      expect(Levels.at(3).meets(3, 1), isTrue);
      expect(Levels.at(3).meets(4, 1), isFalse);
      expect(Levels.at(4).meets(1, 1), isFalse);
      expect(Levels.at(4).meets(2, 60), isFalse);
    });
  });

  group('the play', () {
    test('opens on six and ten, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.stickers, play.packets, play.moves), (6, 10, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a turn moves a dial, by ones or tens, and stops at the ends', () {
      var play = Play.of(Levels.at(0)).set(0, 1);
      expect((play.stickers, play.moves), (7, 1));
      play = play.set(1, 10);
      expect((play.packets, play.moves), (20, 2));
      play = play.set(1, -1);
      expect(play.packets, 19);
      final top = Play.standing(Levels.at(0), 12, 55);
      expect(top.set(0, 1), same(top));
      final wound = top.set(1, 10);
      expect(wound.packets, 60);
      expect(wound.set(1, 1), same(wound));
      final low = Play.standing(Levels.at(0), 1, 1);
      expect(low.set(0, -1), same(low));
      expect(low.set(1, -10), same(low));
    });

    test('back undoes one turn', () {
      final play = Play.of(Levels.at(0)).set(1, 1).set(0, -1);
      expect(play.back.stickers, 6);
      expect(play.back.back.packets, 10);
    });

    test('the pointer walks stickers then packets, and lands every winnable ask', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (0, 1));
      for (final level in Levels.all.where((l) => l.winnable)) {
        var p = Play.of(level);
        var steps = 0;
        while (!p.isDone && steps < 40) {
          p = p.set(p.next!.$1, p.next!.$2);
          steps++;
        }
        expect(p.isDone, isTrue, reason: level.name);
      }
      expect(Play.pointed((0, 1)), 'One more sticker in the set.');
      expect(Play.pointed((1, 10)), 'Up 10 packets.');
      expect(Play.pointed((1, -1)), 'Down 1 packet.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the certain album admits it at sixty packets, or after sixty turns', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 5; k++) {
        play = play.set(1, 10);
      }
      expect(play.packets, 60);
      expect(play.gaveUp, isTrue);
      expect(play.chance.compareTo(Frac.one), lessThan(0));
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 60; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect((wander.moves, wander.gaveUp), (60, true));
    });

    test('the why tells the harmonic number and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('n times the n-th harmonic number'));
      expect(words, contains('This is ask 5, The Certain Album.'));
      expect(words, contains('tried in full'));
    });
  });
}
