import 'package:flutter_test/flutter_test.dart';
import 'package:candleford/party/levels.dart';
import 'package:candleford/party/play.dart';
import 'package:candleford/party/rules.dart';

/// The fraction, the walk and the play, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the fraction', () {
    test('no two sharing is the falling product over the power', () {
      expect(Rules.shared(365, 1), (BigInt.zero, BigInt.from(365)));
      expect(Rules.shared(365, 2), (BigInt.from(365), BigInt.from(365 * 365)));
      final (p, q) = Rules.shared(7, 3);
      expect((p, q), (BigInt.from(343 - 210), BigInt.from(343)));
    });

    test('in a hundred, cut not rounded', () {
      expect(Rules.inHundred(365, 23, places: 4), '50.7297');
      expect(Rules.inHundred(365, 22, places: 4), '47.5695');
      expect(Rules.inHundred(365, 23), '50.72');
      expect(Rules.inHundred(365, 41, places: 4), '90.3151');
      expect(Rules.inHundred(365, 57, places: 4), '99.0122');
      expect(Rules.inHundred(12, 5, places: 4), '61.8055');
      expect(Rules.inHundred(365, 366), '100.00');
      expect(Rules.inHundred(365, 1), '0.00');
    });

    test('the fewest for each mark', () {
      expect(Rules.fewest(365, 1, 2), 23);
      expect(Rules.fewest(365, 9, 10), 41);
      expect(Rules.fewest(365, 99, 100), 57);
      expect(Rules.fewest(365, 1, 1), 366);
      expect(Rules.fewest(12, 1, 2), 5);
      expect(Rules.fewest(12, 1, 1), 13);
    });

    test('certain at the pigeonhole and not before', () {
      expect(Rules.certain(365, 366), isTrue);
      expect(Rules.certain(365, 365), isFalse);
      expect(Rules.certain(12, 13), isTrue);
      expect(Rules.certain(12, 12), isFalse);
      final (p, q) = Rules.shared(365, 365);
      expect((q - p).toString().length, 779);
      expect(q.toString().length, 936);
    });

    test('the walk agrees with the fraction on small years', () {
      for (final (days, n) in [(7, 4), (5, 5), (12, 4), (3, 4)]) {
        final (ws, wa) = Rules.sharedByWalk(days, n);
        final (fs, fa) = Rules.shared(days, n);
        expect(ws * fa, fs * wa, reason: 'year $days, $n guests');
      }
      expect(Rules.sharedByWalk(7, 5), (BigInt.from(14287), BigInt.from(16807)));
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Certain Day']);
      expect(Levels.at(4).cap, 365);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'gather the fewest guests that make a shared birthday more likely than not');
      expect(Levels.at(1).task, 'gather the fewest guests that make a shared birthday at least nine in ten');
      expect(Levels.at(3).task, 'gather the fewest guests of a twelve-month year that make a shared birth month more likely than not');
      expect(Levels.at(4).task, 'gather fewer than 366 guests so that a shared birthday is certain');
    });

    test('an ask is met by the fewest and by nothing else', () {
      expect(Levels.at(0).meets(23), isTrue);
      expect(Levels.at(0).meets(22), isFalse);
      expect(Levels.at(0).meets(24), isFalse);
      expect(Levels.at(1).meets(41), isTrue);
      expect(Levels.at(2).meets(57), isTrue);
      expect(Levels.at(3).meets(5), isTrue);
      expect(Levels.at(3).meets(4), isFalse);
      for (var n = 1; n <= 365; n++) {
        expect(Levels.at(4).meets(n), isFalse);
      }
    });
  });

  group('the play', () {
    test('opens with one guest', () {
      final play = Play.of(Levels.at(0));
      expect(play.guests, 1);
      expect(play.inHundred, '0.00');
      expect(play.isDone, isFalse);
    });

    test('turns by ones and tens, within one and the cap', () {
      var play = Play.of(Levels.at(3));
      play = play.turn(10);
      expect(play.guests, 11);
      play = play.turn(10);
      expect(play.guests, 13);
      expect(play.moves, 2);
      play = play.turn(1);
      expect(play.guests, 13);
      expect(play.moves, 2);
      play = play.turn(-10).turn(-10);
      expect(play.guests, 1);
    });

    test('back undoes one press', () {
      final play = Play.of(Levels.at(0)).turn(10);
      expect(play.back.guests, 1);
    });

    test('the even chance lands at twenty-three', () {
      var play = Play.of(Levels.at(0));
      play = play.turn(10).turn(10).turn(1).turn(1);
      expect(play.guests, 23);
      expect(play.isDone, isTrue);
      expect(play.moves, 4);
    });

    test('the certain day gives up after twenty-four presses', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        expect(play.isOver, isFalse);
        play = play.turn(k.isEven ? 10 : -1);
      }
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer steps toward the fewest', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, 10);
      play = play.turn(10).turn(10).turn(10).turn(10);
      expect(play.guests, 41);
      expect(play.isDone, isTrue);
      play = Play.of(Levels.at(0)).turn(10).turn(10).turn(10);
      // Past the fewest: the pointer steps back.
      expect(play.guests, 31);
      expect(play.isDone, isFalse);
      expect(play.next, -1);
      expect(play.turn(-10).next, 1);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var presses = 0;
        while (!play.isDone && presses < 40) {
          play = play.turn(play.next!);
          presses++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
