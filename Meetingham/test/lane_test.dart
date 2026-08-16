import 'package:flutter_test/flutter_test.dart';
import 'package:meetingham/lane/levels.dart';
import 'package:meetingham/lane/play.dart';
import 'package:meetingham/lane/rules.dart';

/// The crossing, the product, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the lanes', () {
    test('gates, the crossing and Ceva agree', () {
      expect(Rules.gateD(3), (9, 3));
      expect(Rules.gateE(3), (0, 9));
      expect(Rules.gateF(3), (3, 0));
      expect(Rules.meetByCrossing(6, 6, 6), isTrue);
      expect(Rules.meetByCeva(6, 6, 6), isTrue);
      expect(Rules.meetByCrossing(4, 4, 4), isFalse);
      expect(Rules.meetByCrossing(4, 8, 6), isTrue);
      expect(Rules.product(4, 8, 6), (192, 192));
      expect(Rules.product(4, 4, 4), (64, 512));
      expect(Rules.meetingPoint(6, 6, 6), (4, 4, 1));
      expect(Rules.meetingPoint(4, 8, 6), (24, 12, 5));
      var meetings = 0;
      for (var d = 1; d < 12; d++) {
        for (var e = 1; e < 12; e++) {
          for (var f = 1; f < 12; f++) {
            expect(Rules.meetByCrossing(d, e, f), Rules.meetByCeva(d, e, f), reason: '$d $e $f');
            if (Rules.meetByCeva(d, e, f)) meetings++;
          }
        }
      }
      expect(meetings, 31);
      expect(Rules.settings, 1331);
      expect(Rules.ratio(4), '1:2');
      expect(Rules.ratio(9), '3:1');
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Thirds']);
      for (final level in Levels.all) {
        final (met, all, _) = Rules.sweep(level.meets);
        expect((met, all), (level.ways, 1331), reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2, aim.$3), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the three gates so the lanes meet, every gate at the middle of its side');
      expect(Levels.at(4).task, 'set every gate a third of the way from its corner, the same way round, so the lanes meet');
    });

    test('an ask is met by gates that meet as told', () {
      expect(Levels.at(0).meets(6, 6, 6), isTrue);
      expect(Levels.at(0).meets(4, 8, 6), isFalse);
      expect(Levels.at(1).meets(4, 8, 6), isTrue);
      expect(Levels.at(1).meets(6, 6, 6), isFalse);
      expect(Levels.at(2).meets(3, 6, 9), isTrue);
      expect(Levels.at(2).meets(3, 9, 6), isTrue);
      expect(Levels.at(2).meets(3, 3, 3), isFalse);
      expect(Levels.at(3).meets(4, 8, 6), isTrue);
      expect(Levels.at(3).meets(4, 8, 5), isFalse);
      expect(Levels.at(4).meets(4, 4, 4), isFalse);
    });
  });

  group('the play', () {
    test('opens with the gates at three, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.gates, [3, 3, 3]);
        expect(play.meet, isFalse);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap moves a gate, the same again is nothing, and the ends hold', () {
      var play = Play.of(Levels.at(0)).set(0, 6);
      expect(play.gates, [6, 3, 3]);
      expect(play.moves, 1);
      expect(play.set(0, 6), same(play));
      expect(play.set(1, 0), same(play));
      expect(play.set(2, 12), same(play));
      play = play.set(1, 6).set(2, 6);
      expect(play.meet, isTrue);
      expect(play.isDone, isTrue);
      expect(play.set(0, 1), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(0, 6).set(1, 6);
      expect(play.back.gates, [6, 3, 3]);
      expect(play.back.back.gates, [3, 3, 3]);
    });

    test('the pointer walks gate by gate to the aim, and lands every winnable ask', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, (0, 4));
      for (final level in Levels.all.where((l) => l.winnable)) {
        var p = Play.of(level);
        var steps = 0;
        while (!p.isDone && steps < 6) {
          p = p.set(p.next!.$1, p.next!.$2);
          steps++;
        }
        expect(p.isDone, isTrue, reason: level.name);
      }
      expect(Play.pointed((0, 4)), 'Move gate D to 4 paces from B.');
      expect(Play.pointed((2, 6)), 'Move gate F to 6 paces from A.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the thirds admit it once every gate is a third along, or after thirty taps', () {
      var play = Play.of(Levels.at(4)).set(0, 4).set(1, 4);
      expect(play.gaveUp, isFalse);
      play = play.set(2, 4);
      expect(play.gaveUp, isTrue);
      expect(play.meet, isFalse);
      expect(play.product, (64, 512));
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        wander = wander.set(0, k.isEven ? 5 : 7);
      }
      expect((wander.moves, wander.gaveUp), (30, true));
    });

    test('the why tells Ceva and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Ceva showed in 1678'));
      expect(words, contains('This is ask 5, The Thirds.'));
      expect(words, contains('tried in full'));
    });
  });
}
