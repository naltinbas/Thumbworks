import 'package:flutter_test/flutter_test.dart';
import 'package:knowsley/pair/levels.dart';
import 'package:knowsley/pair/play.dart';
import 'package:knowsley/pair/rules.dart';

/// The pairs, the sieve, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the pairs', () {
    test('the pairs, the splits and the four things', () {
      expect(Rules.pairs, hasLength(2352));
      expect(Rules.pairs.first, (2, 3));
      expect(Rules.pairs.last, (49, 51));
      expect(Rules.valid(2, 2), isFalse);
      expect(Rules.valid(1, 5), isFalse);
      expect(Rules.valid(49, 52), isFalse);
      expect(Rules.valid(49, 51), isTrue);
      expect(Rules.splitsOfProduct(52), [(2, 26), (4, 13)]);
      expect(Rules.splitsOfProduct(6), [(2, 3)]);
      expect(Rules.splitsOfProduct(18), [(2, 9), (3, 6)]);
      expect(Rules.splitsOfProduct(16), [(2, 8)]);
      expect(Rules.splitsOfSum(17), hasLength(7));
      expect(Rules.splitsOfSum(4), isEmpty);
      expect(Rules.pInDark(52), isTrue);
      expect(Rules.pInDark(6), isFalse);
      expect(Rules.sKnewDark(17), isTrue);
      expect(Rules.sKnewDark(14), isFalse);
      expect(Rules.sKnewDark(11), isTrue);
      expect(Rules.pNowKnows(52), isTrue);
      expect(Rules.pNowKnows(18), isTrue);
      expect(Rules.sNowKnows(17), isTrue);
      expect(Rules.sNowKnows(11), isFalse);
      expect(Rules.said(4, 13), (true, true, true, true));
      expect(Rules.said(2, 9), (true, true, true, false));
      expect(Rules.said(3, 4), (true, false, false, false));
      expect(Rules.said(2, 3), (false, false, false, false));
      expect(Rules.speakingSums, [11, 17, 23, 27, 29, 35, 37, 41, 47, 53]);
      expect(Rules.primeSplit(14), (3, 11));
      expect(Rules.primeSplit(6), isNull);
      expect(Rules.isPrime(53), isTrue);
      expect(Rules.isPrime(51), isFalse);
      expect(Rules.tell((4, 13)), '4 and 13');
    });

    test('the sieve: the four things asked of every pair agree with the narrowing, down to 4 and 13', () {
      var one = 0, two = 0, three = 0, four = 0, evenTwo = 0;
      (int, int)? answer;
      for (final (x, y) in Rules.pairs) {
        final (a, b, c, d) = Rules.said(x, y);
        if (a) one++;
        if (b) two++;
        if (c) three++;
        if (d) {
          four++;
          answer = (x, y);
        }
        if (b && (x + y).isEven) evenTwo++;
      }
      expect((one, two, three, four), (1747, 145, 86, 1));
      expect(answer, (4, 13));
      expect(evenTwo, 0);
      final narrowed = Rules.narrowed;
      expect(narrowed.map((s) => s.length).toList(), [1747, 145, 86, 1]);
      expect(narrowed.last, {(4, 13)});
      for (var s = 8; s <= 100; s += 2) {
        final split = Rules.primeSplit(s)!;
        expect(Rules.pInDark(split.$1 * split.$2), isFalse, reason: '$s');
      }
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Even Sum']);
      for (final level in Levels.all) {
        var ways = 0;
        for (final (x, y) in Rules.pairs) {
          if (level.meets(x, y)) ways++;
        }
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, (2, 3));
      expect(Levels.at(1).aim, (2, 9));
      expect(Levels.at(2).aim, (2, 9));
      expect(Levels.at(3).aim, (4, 13));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set two numbers whose product tells P them at once');
      expect(Levels.at(1).task, 'set two numbers whose sum lets S say she knew P did not know');
      expect(Levels.at(2).task, 'set two numbers P knows once S has said she knew he did not');
      expect(Levels.at(3).task, 'set the two numbers S knows too, all four things said');
      expect(Levels.at(4).task, 'set two numbers with an even sum that lets S say she knew P did not know');
    });

    test('an ask is met by the pair', () {
      expect(Levels.at(0).meets(2, 3), isTrue);
      expect(Levels.at(0).meets(3, 4), isFalse);
      expect(Levels.at(1).meets(3, 8), isTrue);
      expect(Levels.at(1).meets(3, 4), isFalse);
      expect(Levels.at(2).meets(2, 9), isTrue);
      expect(Levels.at(2).meets(4, 13), isTrue);
      expect(Levels.at(3).meets(4, 13), isTrue);
      expect(Levels.at(3).meets(2, 9), isFalse);
      expect(Levels.at(4).meets(3, 11), isFalse);
      expect(Levels.at(0).meets(2, 2), isFalse);
    });
  });

  group('the play', () {
    test('opens at 3 and 4', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.x, play.y, play.moves), (3, 4, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('steps keep the pair a pair', () {
      final play = Play.of(Levels.at(3));
      expect(play.step('x', 1), same(play));
      expect(play.step('y', -1), same(play));
      final up = play.step('y', 1);
      expect((up.x, up.y, up.moves), (3, 5, 1));
      expect((up.sum, up.product), (8, 15));
      final down = play.step('x', -1);
      expect((down.x, down.y), (2, 4));
      expect(Play.standing(Levels.at(3), 49, 51).step('y', 1).y, 51);
      expect(Play.standing(Levels.at(3), 2, 3).step('x', -1).x, 2);
    });

    test('back undoes one step', () {
      final play = Play.of(Levels.at(3)).step('y', 1).step('y', 1);
      expect(play.back.y, 5);
      expect(play.back.back.y, 4);
    });

    test('the pointer steps y first, then x', () {
      final play = Play.of(Levels.at(3));
      expect(play.next, ('y', 1));
      expect(Play.pointed(('y', 1)), 'Step y up.');
      expect(Play.of(Levels.at(0)).next, ('x', -1));
      expect(Play.pointed(('x', -1)), 'Step x down.');
      expect(Play.standing(Levels.at(3), 3, 13).next, ('x', 1));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 60) {
          final (which, by) = play.next!;
          play = play.step(which, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
      var answer = Play.of(Levels.at(3));
      while (!answer.isDone) {
        final (which, by) = answer.next!;
        answer = answer.step(which, by);
      }
      expect((answer.x, answer.y, answer.moves), (4, 13, 10));
    });

    test('the even sum admits it after three even sums, or sixteen taps', () {
      var play = Play.of(Levels.at(4)).step('y', 1);
      expect(play.seen, {8});
      expect(play.gaveUp, isFalse);
      play = play.step('y', 1).step('y', 1).step('y', 1);
      expect(play.seen, {8, 10});
      expect(play.gaveUp, isFalse);
      play = play.step('y', 1);
      expect(play.seen, {8, 10, 12});
      expect(play.gaveUp, isTrue);
      expect(play.tellingSplit, (3, 9));
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 16; k++) {
        wander = wander.step('y', k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 16);
    });

    test('the why tells Freudenthal and the sieve', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Freudenthal set it in 1969'));
      expect(words, contains('2,352'));
      expect(words, contains('This is ask 5, The Even Sum.'));
      expect(words, contains('asked in full'));
    });
  });
}
