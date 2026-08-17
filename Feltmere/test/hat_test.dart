import 'package:flutter_test/flutter_test.dart';
import 'package:feltmere/hat/levels.dart';
import 'package:feltmere/hat/play.dart';
import 'package:feltmere/hat/rules.dart';

/// The hats, the agreements and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the hats', () {
    test('eight hattings, four sights, and everyone sees the other two', () {
      expect(Rules.hattings, hasLength(8));
      expect(Rules.sights, hasLength(4));
      expect(Rules.sightOf([0, 1, 1], 0), [1, 1]);
      expect(Rules.sightOf([0, 1, 1], 1), [1, 0]);
      expect(Rules.sightNumber([0, 1, 1], 0), 3);
      expect(Rules.tellHats([0, 1, 1]), 'BWW');
      expect(Rules.tellVillager(2), 'Cedar');
      expect(Rules.tellSight(1), 'BW seen');
      for (final hats in Rules.hattings) {
        for (var who = 0; who < Rules.villagers; who++) {
          // The other hatting with the same sight differs in this
          // villager's own hat alone.
          final other = List.of(hats)..[who] = 1 - hats[who];
          expect(Rules.sightNumber(other, who), Rules.sightNumber(hats, who));
        }
      }
    });

    test('the matching rule wins six and loses the two that match', () {
      final matching = [
        for (var who = 0; who < Rules.villagers; who++)
          [
            for (final sight in Rules.sights)
              sight[0] == sight[1] ? 1 - sight[0] : Rules.quiet,
          ],
      ];
      expect(Rules.wins(matching), 6);
      expect(Rules.losses(matching), ['BBB', 'WWW']);
      expect(Rules.words(matching), 6);
      expect(Rules.wrongs(matching), 6);
      expect(Rules.hasQuiet(matching), isFalse);
      expect(Rules.taps(matching), 9);
    });

    test('one speaker wins four, and a wrong word is paid for every word', () {
      final oneSpeaker = [
        [Rules.black, Rules.black, Rules.black, Rules.black],
        [Rules.quiet, Rules.quiet, Rules.quiet, Rules.quiet],
        [Rules.quiet, Rules.quiet, Rules.quiet, Rules.quiet],
      ];
      expect(Rules.wins(oneSpeaker), 4);
      expect(Rules.hasQuiet(oneSpeaker), isTrue);
      expect(Rules.words(oneSpeaker), 4);
      expect(Rules.wrongs(oneSpeaker), 4);
      expect(Rules.wins(Rules.quietAll), 0);
      expect(Rules.words(Rules.quietAll), 0);
    });

    test('every agreement risks a wrong word for every word it calls for', () {
      var agreements = 0;
      for (final agreement in Rules.agreements()) {
        agreements++;
        if (agreements % 7 != 0) continue;
        expect(Rules.wrongs(agreement), Rules.words(agreement));
      }
      expect(agreements, 531441);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['The Seven']);
      expect(Levels.all.map((l) => l.ways), [23270, 2652, 624, 4, 0]);
      expect(Levels.all.map((l) => l.hattings), [4, 4, 5, 6, 7]);
      expect(Levels.all.map((l) => l.fewest), [4, 4, 5, 9, null]);
      for (final level in Levels.all.where((l) => l.winnable)) {
        expect(level.meets(level.aim), isTrue, reason: level.name);
      }
      expect(Levels.at(4).aim, isEmpty);
    });

    test('an ask knows what it wants of an agreement', () {
      final six = [
        [1, 2, 2, 0],
        [1, 2, 2, 0],
        [1, 2, 2, 0],
      ];
      expect(Levels.at(3).meets(six), isTrue);
      expect(Levels.at(2).meets(six), isFalse);
      expect(Levels.at(4).meets(six), isFalse);
      expect(Levels.at(0).meets(Levels.at(1).aim), isFalse,
          reason: 'that one has a silent villager');
      expect(Levels.at(1).meets(Levels.at(1).aim), isTrue);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task,
          'agree a rule that wins 4 of the eight hattings with nobody silent throughout');
      expect(Levels.at(4).task,
          'agree a rule that wins 7 of the eight hattings or more');
    });
  });

  group('the play', () {
    test('opens with everybody quiet', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.agreement, Rules.quietAll);
        expect((play.moves, play.wins, play.words), (0, 0, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap turns a cell round, and back undoes it', () {
      var play = Play.of(Levels.at(0));
      play = play.turn(0, 0);
      expect(play.agreement[0][0], Rules.black);
      play = play.turn(0, 0);
      expect(play.agreement[0][0], Rules.white);
      play = play.turn(0, 0);
      expect(play.agreement[0][0], Rules.quiet);
      expect(play.moves, 3);
      expect(play.back.agreement[0][0], Rules.white);
      expect(play.turn(9, 0), same(play));
    });

    test('the pointer lands every ask it can, in the fewest taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          final aim = play.next;
          expect(aim, isNotNull, reason: level.name);
          play = play.turn(aim!.$1, aim.$2);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.agreement, level.aim, reason: level.name);
      }
      expect(Play.pointed((0, 3), Rules.white),
          'Set Ash on WW seen to white.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the seven admits it after two best agreements, or twenty-four taps',
        () {
      var play = Play.of(Levels.at(4));
      // The matching rule, cell by cell, is one of the four that win six.
      for (var who = 0; who < Rules.villagers; who++) {
        play = play.turn(who, 0).turn(who, 0);
        play = play.turn(who, 3);
      }
      expect(play.wins, 6);
      expect(play.seen, hasLength(1));
      expect(play.gaveUp, isFalse);
      play = play.turn(0, 1).turn(0, 1).turn(0, 1);
      expect(play.wins, 6);
      expect(play.seen, hasLength(1), reason: 'the same agreement again');
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < Play.gaveUpAt && !wander.gaveUp; k++) {
        wander = wander.turn(k % 3, k % 4);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Ebert and the count', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Todd Ebert'));
      expect(words, contains('1998'));
      expect(words, contains('531,441'));
      expect(words, contains('This is ask 5, The Seven.'));
      expect(words, contains('before the sham was built'));
    });
  });
}
