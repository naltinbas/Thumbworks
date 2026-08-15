import 'package:flutter_test/flutter_test.dart';
import 'package:chimewell/coil/levels.dart';
import 'package:chimewell/coil/play.dart';
import 'package:chimewell/coil/rules.dart';

/// The fractions, the asks and the play, checked at the domain: nothing
/// here touches a widget.
void main() {
  BigInt n(int x) => BigInt.from(x);

  group('the fractions', () {
    test('a note is 3 to the fifths over 2 to something, in lowest terms', () {
      expect(Rules.note(0, 0), (n(1), n(1)));
      expect(Rules.note(1, 0), (n(3), n(2)));
      expect(Rules.note(2, -1), (n(9), n(8)));
      expect(Rules.note(4, -2), (n(81), n(64)));
      expect(Rules.note(-5, 3), (n(256), n(243)));
      expect(Rules.note(12, 0), (n(531441), n(4096)));
      expect(Rules.note(12, -7), (n(531441), n(524288)));
      expect(Rules.note(-12, 7), (n(524288), n(531441)));
      expect(Rules.settings, 425);
    });

    test('the cents agree with the fractions', () {
      expect(Rules.cents(1, 0), closeTo(701.955, 0.001));
      expect(Rules.cents(12, -7), closeTo(23.460, 0.001));
      expect(Rules.cents(-5, 3), closeTo(90.225, 0.001));
      expect(Rules.cents(0, 3), 3600);
      for (final (f, o) in [(1, 0), (12, -7), (-5, 3), (7, -4), (-12, 8)]) {
        expect(Rules.centsOf(Rules.note(f, o)), closeTo(Rules.cents(f, o), 1e-6));
      }
    });

    test('home, sharp and the twentieth', () {
      expect(Rules.home(Rules.note(0, 0)), isTrue);
      expect(Rules.home(Rules.note(12, -7)), isFalse);
      expect(Rules.sharp(Rules.note(12, -7)), isTrue);
      expect(Rules.sharp(Rules.note(-12, 7)), isFalse);
      expect(Rules.within(Rules.note(12, -7), 20), isTrue);
      expect(Rules.within(Rules.note(-12, 7), 20), isTrue);
      expect(Rules.within(Rules.note(5, -3), 20), isFalse);
      expect(Rules.within(Rules.note(7, -4), 20), isFalse);
      expect(Rules.within(Rules.note(5, -3), 19), isTrue);
    });

    test('the words', () {
      expect(Rules.told(12, -7), 'twelve fifths up and seven octaves down');
      expect(Rules.told(0, 0), 'no fifths and no octaves');
      expect(Rules.told(1, 1), 'one fifth up and one octave up');
      expect(Rules.told(-5, 3), 'five fifths down and three octaves up');
      expect(Rules.fraction(Rules.note(12, -7)), '531,441/524,288');
      expect(Rules.fraction(Rules.note(2, -1)), '9/8');
      expect(Rules.centsTold(Rules.cents(5, -3)), '90.22 cents flat');
      expect(Rules.centsTold(Rules.cents(12, -7)), '23.46 cents sharp');
      expect(Rules.commas(n(1234567)), '1,234,567');
    });

    test('the sweep', () {
      final (met, all, first) = Rules.sweep((f, o) => f != 0 && Rules.within(Rules.note(f, o), 20));
      expect((met, all, first), (2, 425, (-12, 7)));
      expect(Rules.sweep((f, o) => f != 0 && Rules.home(Rules.note(f, o))), (0, 425, null));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Return']);
      for (final level in Levels.all) {
        final (met, all, _) = Rules.sweep(level.meets);
        expect((met, all), (level.ways, 425), reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the fifths and the octaves so the note sounds 9/8 of the start');
      expect(Levels.at(3).task, 'set the fifths and the octaves so the note comes within a twentieth of the start, one fifth or more in the stack');
      expect(Levels.at(4).task, 'set the fifths and the octaves so the note comes home exactly, one fifth or more in the stack');
    });

    test('an ask is met by the setting that sounds it', () {
      expect(Levels.at(0).meets(2, -1), isTrue);
      expect(Levels.at(0).meets(2, 0), isFalse);
      expect(Levels.at(3).meets(-12, 7), isTrue);
      expect(Levels.at(3).meets(12, -6), isFalse);
      expect(Levels.at(3).meets(0, 0), isFalse);
      expect(Levels.at(4).meets(0, 0), isFalse);
      expect(Levels.at(4).meets(12, -7), isFalse);
    });
  });

  group('the play', () {
    test('opens at the start', () {
      final play = Play.of(Levels.at(0));
      expect((play.fifths, play.octaves, play.moves), (0, 0, 0));
      expect(Rules.home(play.note), isTrue);
      expect(play.isDone, isFalse);
      expect(play.isOver, isFalse);
    });

    test('a tap turns a dial a step, and a dial at its end stays', () {
      var play = Play.of(Levels.at(0)).set(0, 1);
      expect((play.fifths, play.octaves, play.moves), (1, 0, 1));
      play = play.set(1, -1);
      expect((play.fifths, play.octaves, play.moves), (1, -1, 2));
      final atEnd = Play.standing(Levels.at(0), 12, 8);
      expect(atEnd.set(0, 1), same(atEnd));
      expect(atEnd.set(1, 1), same(atEnd));
      expect(atEnd.set(0, -1).fifths, 11);
      expect(play.set(0, 0), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(0, 1);
      expect(play.back.fifths, 0);
      expect(play.back.back.moves, 0);
    });

    test('the whole tone lands by two fifths and an octave', () {
      final play = Play.of(Levels.at(0)).set(0, 1).set(0, 1).set(1, -1);
      expect(play.note, (n(9), n(8)));
      expect(play.isDone, isTrue);
      expect(play.isOver, isTrue);
      expect(play.set(0, 1), same(play));
    });

    test('the pointer names the dial and the way', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, (0, 1));
      play = play.set(0, 1);
      expect(play.next, (0, 1));
      play = play.set(0, 1);
      expect(play.next, (1, -1));
      expect(Play.pointed((1, -1)), 'Lower the octaves.');
      expect(Play.pointed((0, 1)), 'Raise the fifths.');
      expect(Play.of(Levels.at(2)).next, (0, -1));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer sounds every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          final (which, by) = play.next!;
          play = play.set(which, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.aim!.$1.abs() + level.aim!.$2.abs(), reason: level.name);
      }
    });

    test('the return admits it at the comma, or after forty taps', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        play = play.set(0, 1);
      }
      for (var k = 0; k < 6; k++) {
        play = play.set(1, -1);
      }
      expect(play.gaveUp, isFalse);
      play = play.set(1, -1);
      expect(play.gaveUp, isTrue);
      expect(play.isDone, isFalse);
      expect(play.moves, 19);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 40; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect((wander.moves, wander.fifths, wander.gaveUp), (40, 0, true));
    });

    test('the why tells the comma and the parity', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('531,441 over 524,288, the comma, 23.46 cents'));
      expect(words, contains('This is ask 5, The Return.'));
      expect(words, contains('3 to any power is odd'));
      expect(words, contains('425 of them'));
    });
  });
}
