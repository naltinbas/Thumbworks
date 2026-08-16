import 'package:flutter_test/flutter_test.dart';
import 'package:shortcombe/road/levels.dart';
import 'package:shortcombe/road/play.dart';
import 'package:shortcombe/road/rules.dart';

/// The roads, the settling, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the roads', () {
    test('forty hundred: 65 shut, 80 open', () {
      expect(Rules.settle(40, false), (20, 20, 0));
      expect(Rules.settle(40, true), (0, 0, 40));
      expect(Rules.journey(40, false), 65);
      expect(Rules.journey(40, true), 80);
      expect(Rules.minutes(40, true), (85, 85, 80));
      expect(Rules.minutes(40, false), (65, 65, null));
      expect(Rules.settle(50, true), (5, 5, 40));
      expect(Rules.journey(50, true), 90);
      expect(Rules.journey(20, true), 40);
      expect(Rules.journey(30, true), 60);
      expect(Rules.journey(30, false), 60);
      expect(Rules.verdictOf(20), 'helps');
      expect(Rules.verdictOf(30), 'no odds');
      expect(Rules.verdictOf(32), 'hurts');
      expect(Rules.tell(40), 'forty hundred');
      expect(Rules.tell(28), 'twenty-eight hundred');
      expect(Rules.settings, 60);
    });

    test('the cases and the potential agree on every setting, and no driver gains', () {
      for (var crowd = 2; crowd <= 60; crowd += 2) {
        for (final open in [false, true]) {
          expect(Rules.settleByPotential(crowd, open), Rules.settle(crowd, open), reason: '$crowd $open');
          final (top, bottom, across) = Rules.settle(crowd, open);
          final (t, b, a) = Rules.minutes(crowd, open);
          final journey = Rules.journey(crowd, open);
          if (top > 0) expect(t, journey);
          if (bottom > 0) expect(b, journey);
          if (across > 0) expect(a, journey);
          expect(t, greaterThanOrEqualTo(journey));
          expect(b, greaterThanOrEqualTo(journey));
          if (open) expect(a, greaterThanOrEqualTo(journey));
        }
      }
      expect(Rules.potential(0, 0, 40), 3200);
      expect(Rules.potential(20, 20, 0), 4400);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Big Crowd Helped']);
      for (final level in Levels.all) {
        var n = 0;
        for (var crowd = 2; crowd <= 60; crowd += 2) {
          for (final open in [false, true]) {
            if (level.meets(crowd, open)) n++;
          }
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, (40, false));
      expect(Levels.at(1).aim, (40, true));
      expect(Levels.at(2).aim, (2, true));
      expect(Levels.at(3).aim, (30, false));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'dial the crowd so that, with the shortcut shut, every driver takes 65 minutes');
      expect(Levels.at(2).task, 'open the shortcut on a crowd it speeds up');
      expect(Levels.at(4).task, 'open the shortcut on a crowd past thirty hundred that it speeds up');
    });

    test('an ask is met by the crowd and the shortcut', () {
      expect(Levels.at(0).meets(40, false), isTrue);
      expect(Levels.at(0).meets(40, true), isFalse);
      expect(Levels.at(1).meets(40, true), isTrue);
      expect(Levels.at(1).meets(38, true), isFalse);
      expect(Levels.at(2).meets(28, true), isTrue);
      expect(Levels.at(2).meets(28, false), isFalse);
      expect(Levels.at(2).meets(30, true), isFalse);
      expect(Levels.at(3).meets(30, true), isTrue);
      expect(Levels.at(3).meets(30, false), isTrue);
      expect(Levels.at(4).meets(32, true), isFalse);
      expect(Levels.at(0).meets(41, false), isFalse);
    });
  });

  group('the play', () {
    test('opens on twenty hundred with the shortcut shut', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.crowd, play.open, play.moves), (20, false, 0));
        expect(play.journey, 55);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('the crowd turns two hundred a tap and stops at the ends, and the shortcut turns over', () {
      var play = Play.of(Levels.at(0)).set(0, 1);
      expect((play.crowd, play.moves), (22, 1));
      play = play.set(1, 1);
      expect(play.open, isTrue);
      expect(play.journey, 44);
      play = play.set(1, 1);
      expect(play.open, isFalse);
      var low = Play.of(Levels.at(0));
      while (low.crowd > 2) {
        low = low.set(0, -1);
      }
      expect(low.set(0, -1), same(low));
      expect(low.moves, 9);
      var high = Play.of(Levels.at(3));
      while (high.crowd < 60 && !high.isOver) {
        high = high.set(0, 1);
      }
      expect(high.isDone, isTrue);
      expect(high.crowd, 30);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(0, 1).set(1, 1);
      expect(play.back.open, isFalse);
      expect(play.back.back.crowd, 20);
    });

    test('the pointer turns the crowd first, then the shortcut', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (0, 1));
      while (play.crowd < 40) {
        play = play.set(0, 1);
      }
      expect(play.next, (1, 1));
      play = play.set(1, 1);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((0, 1), open: false), 'Turn the crowd up.');
      expect(Play.pointed((1, 1), open: false), 'Open the shortcut.');
      expect(Play.pointed((1, 1), open: true), 'Shut the shortcut.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          final (which, way) = play.next!;
          play = play.set(which, way);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the big crowd admits it once the shortcut is open past thirty, or after twelve taps', () {
      var play = Play.of(Levels.at(4)).set(1, 1);
      expect(play.gaveUp, isFalse);
      play = play.set(1, 1);
      while (play.crowd < 32) {
        play = play.set(0, 1);
      }
      expect(play.gaveUp, isFalse);
      play = play.set(1, 1);
      expect((play.crowd, play.open), (32, true));
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Braess and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Braess found it in 1968'));
      expect(words, contains('60 settings'));
      expect(words, contains('This is ask 5, The Big Crowd Helped.'));
      expect(words, contains('settled both ways'));
    });
  });
}
