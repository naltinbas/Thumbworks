import 'package:flutter_test/flutter_test.dart';
import 'package:pursewell/purse/play.dart';
import 'package:pursewell/purse/purses.dart';
import 'package:pursewell/purse/rules.dart';

/// The law of the purse, held to.
void main() {
  group('the rules', () {
    test('neighbours are coins side by side in the coinage', () {
      expect(Rules.neighbours([3, 8]), isEmpty);
      expect(Rules.neighbours([2, 3]), [(2, 3)]);
      expect(Rules.neighbours([1, 2, 5]), [(1, 2)]);
    });

    test('the law holds to a hundred', () {
      expect(Rules.lawHolds(), isTrue);
    });

    test('every shipped price pays its one way', () {
      expect(Rules.payments(11).single, [3, 8]);
      expect(Rules.payments(19).single, [1, 5, 13]);
      expect(Rules.payments(30).single, [1, 8, 21]);
      expect(Rules.payments(47).single, [13, 34]);
      expect(Rules.payments(12).single, [1, 3, 8]);
    });

    test('the greedy walks to the same coins', () {
      for (final price in [11, 19, 30, 47, 12]) {
        expect(List.of(Rules.greedy(price))..sort(),
            List.of(Rules.payments(price).single)..sort(),
            reason: '$price');
      }
    });

    test('seventeen cannot dodge the thirteen', () {
      expect(Rules.payments(17).single, contains(13));
    });
  });

  group('the play', () {
    test('coins move in and out of the tray', () {
      var play = Play.of(Purses.at(0));
      play = play.tapAt(8);
      expect(play.tray, [8]);
      expect(play.total, 8);
      expect(play.moves, 1);
      play = play.tapAt(8);
      expect(play.tray, isEmpty);
      expect(play.moves, 2);
    });

    test('the eleven pays with eight and three', () {
      final play = Play.of(Purses.at(0)).tapAt(8).tapAt(3);
      expect(play.isDone, isTrue);
      expect(play.tapAt(1), same(play));
    });

    test('a neighbour pair blocks the paying', () {
      final play = Play.of(Purses.at(0)).tapAt(8).tapAt(2).tapAt(1);
      expect(play.total, 11);
      expect(play.neighbours, [(1, 2)]);
      expect(play.isDone, isFalse);
    });

    test('the second way refuses the shown payment', () {
      final play =
          Play.of(Purses.at(4)).tapAt(8).tapAt(3).tapAt(1);
      expect(play.total, 12);
      expect(play.neighbours, isEmpty);
      expect(play.isDone, isFalse);
    });

    test('back takes back a coin', () {
      var play = Play.of(Purses.at(0)).tapAt(8);
      expect(play.back.tray, isEmpty);
      expect(play.back.moves, 0);
      expect(Play.of(Purses.at(0)).back.moves, 0);
    });

    test('show me pays the purse home', () {
      var play = Play.of(Purses.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 8) {
        final aim = play.next;
        expect(aim, isNotNull);
        expect(aim!.$2, isTrue);
        play = play.tapAt(aim.$1);
      }
      expect(play.isDone, isTrue);
      expect(play.tray.toSet(), {1, 8, 21});
    });

    test('show me takes a stray back first', () {
      final play = Play.of(Purses.at(0)).tapAt(21);
      final aim = play.next;
      expect(aim, isNotNull);
      expect(aim!.$1, 21);
      expect(aim.$2, isFalse);
    });

    test('the hopeless purse has nothing to point at', () {
      expect(Play.of(Purses.at(4)).next, isNull);
    });

    test('the hopeless purse admits it after twelve moves', () {
      var play = Play.of(Purses.at(4));
      for (var move = 0; move < Play.gaveUpAt; move++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable purse never gives up', () {
      var play = Play.of(Purses.at(0));
      for (var move = 0; move < Play.gaveUpAt; move++) {
        play = play.tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
