import 'package:flutter_test/flutter_test.dart';
import 'package:knaveley/isle/levels.dart';
import 'package:knaveley/isle/play.dart';
import 'package:knaveley/isle/rules.dart';

/// The tellings, the namings and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the island', () {
    test('a telling holds or it does not', () {
      const naming = [true, false, true];
      expect(Rules.holds([Rules.isKnight, 0], 1, naming), isTrue);
      expect(Rules.holds([Rules.isKnave, 0], 1, naming), isFalse);
      expect(Rules.holds([Rules.same, 0, 2], 1, naming), isTrue);
      expect(Rules.holds([Rules.different, 0, 1], 2, naming), isTrue);
      expect(Rules.holds([Rules.someKnave, 0, 2], 1, naming), isFalse);
      expect(Rules.holds([Rules.selfKnave], 1, naming), isTrue);
      expect(Rules.tellName(1), 'Birch');
      expect(Rules.tellTelling([Rules.isKnave, 2], 0), 'Cedar is a knave');
      expect(Rules.tellTelling([Rules.selfKnave], 0), 'I am a knave');
      expect(Rules.tellNaming([true, false]),
          'Alder the knight, Birch the knave');
    });

    test('nobody can call themselves a knave, on any island', () {
      for (var many = 1; many <= 5; many++) {
        for (final naming in Rules.namings(many)) {
          expect(naming[0] == Rules.holds([Rules.selfKnave], 0, naming),
              isFalse);
        }
        expect(Rules.namings(many).length, 1 << many);
      }
    });

    test('a naming holds when nobody is caught out', () {
      final tellings = Levels.at(1).tellings;
      for (final naming in Rules.namings(3)) {
        expect(Rules.consistent(tellings, naming),
            Rules.caught(tellings, naming).isEmpty,
            reason: Rules.tellNaming(naming));
      }
      expect(Rules.caught(tellings, [false, true, false]), isEmpty);
      expect(Rules.caught(tellings, [true, true, true]), isNotEmpty);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['The Paradox']);
      for (final level in Levels.all) {
        var n = 0;
        for (final naming in Rules.namings(level.villagers)) {
          if (level.meets(naming)) n++;
        }
        expect(n, level.ways, reason: level.name);
        expect(level.answers, hasLength(level.ways), reason: level.name);
      }
      expect(Levels.all.map((l) => l.villagers), [2, 3, 4, 4, 3]);
      expect(Levels.all.map((l) => l.ways), [1, 1, 2, 1, 0]);
      expect(Levels.all.map((l) => l.namings), [4, 8, 16, 16, 8]);
      expect(Levels.all.map((l) => l.fewest), [2, 2, 1, 3, null]);
      expect(Levels.at(1).answers.single, [false, true, false]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task,
          'name the 2 villagers so that every telling holds');
      expect(Levels.at(4).task,
          'name the 3 villagers so that every telling holds');
    });
  });

  group('the play', () {
    test('opens with everybody called a knight', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.kinds, List.filled(level.villagers, Rules.knight));
        expect(play.moves, 0);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap turns a villager, and back turns them again', () {
      var play = Play.of(Levels.at(1));
      play = play.turn(0);
      expect(play.kinds, [false, true, true]);
      expect(play.moves, 1);
      expect(play.back.kinds, [true, true, true]);
      expect(play.turn(9), same(play));
    });

    test('the pointer lands every ask it can, in the fewest taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 10) {
          final who = play.next;
          expect(who, isNotNull, reason: level.name);
          play = play.turn(who!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.caught, isEmpty, reason: level.name);
      }
      expect(Play.of(Levels.at(1)).pointed(0), 'Call Alder a knave.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the paradox catches Alder out under every naming', () {
      for (final naming in Rules.namings(3)) {
        final play = Play.standing(Levels.at(4), naming);
        expect(play.caught, contains(0), reason: Rules.tellNaming(naming));
        expect(play.isDone, isFalse);
      }
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < Play.gaveUpAt && !play.gaveUp; k++) {
        play = play.turn(k % 3);
      }
      expect(play.gaveUp, isTrue);
      expect(play.seen.length, greaterThanOrEqualTo(Play.enough));
    });

    test('the why tells Smullyan and the naming', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Raymond Smullyan'));
      expect(words, contains('1978'));
      expect(words, contains('This is ask 5, The Paradox.'));
      expect(words, contains('tried in full before the sham'));
    });
  });
}
