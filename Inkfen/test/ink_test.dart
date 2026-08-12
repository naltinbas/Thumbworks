import 'package:flutter_test/flutter_test.dart';
import 'package:inkfen/ink/lines.dart';
import 'package:inkfen/ink/play.dart';
import 'package:inkfen/ink/rules.dart';

/// The law of the bunting, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final line in Lines.all) {
        expect(
          Rules(line.posts, line.strings).waysTo(line.pot),
          line.ways,
          reason: line.name,
        );
      }
    });

    test('clashes read the inking, post by post', () {
      final rules = Rules(5, Lines.at(0).strings);
      expect(rules.clashes([1, 1, 0, 0]), [(0, 1)]);
      expect(rules.clashes([1, 2, 1, 2]), isEmpty);
      expect(rules.lands([1, 2, 1, 2]), isTrue);
      expect(rules.lands([1, 2, 1, 0]), isFalse);
    });

    test('the full four lands only on its matchings', () {
      final rules = Rules(4, Lines.at(2).strings);
      expect(rules.matchingsHold(3), isTrue);
      expect(rules.lands(const [1, 2, 1, 2, 3, 3]), isTrue);
    });

    test('the mended ring wears some ink exactly once', () {
      final rules = Rules(5, Lines.at(3).strings);
      var spread = true;
      rules.inkings(3, (inks) {
        if (!rules.lands(inks)) return;
        final worn = [0, 0, 0, 0];
        for (final ink in inks) {
          worn[ink]++;
        }
        if (!worn.sublist(1).contains(1)) spread = false;
      });
      expect(spread, isTrue);
    });

    test('dropping any string of the odd ring lands two ways', () {
      for (var drop = 0; drop < 5; drop++) {
        final strings = [
          for (var at = 0; at < 5; at++)
            if (at != drop) Lines.at(4).strings[at],
        ];
        expect(Rules(5, strings).waysTo(2), 2, reason: '$drop');
      }
    });
  });

  group('the play', () {
    test('opens bare and unsettled on every line', () {
      for (final line in Lines.all) {
        final play = Play.of(line);
        expect(play.inked, 0, reason: line.name);
        expect(play.isDone, isFalse, reason: line.name);
        expect(play.isOver, isFalse, reason: line.name);
      }
    });

    test('a dip cycles the pot and back to bare', () {
      var play = Play.of(Lines.at(4));
      play = play.dipAt(0);
      expect(play.inks[0], 1);
      play = play.dipAt(0);
      expect(play.inks[0], 2);
      play = play.dipAt(0);
      expect(play.inks[0], 0);
      expect(play.moves, 3);
    });

    test('back takes back one dip', () {
      final play = Play.of(Lines.at(4)).dipAt(0).dipAt(2);
      expect(play.back.moves, 1);
      expect(play.back.inks[2], 0);
      expect(play.back.back.back, same(play.back.back));
    });

    test('four dips land the two-ink path', () {
      var play = Play.of(Lines.at(0));
      play = play.dipAt(0);
      play = play.dipAt(1).dipAt(1);
      play = play.dipAt(2);
      play = play.dipAt(3).dipAt(3);
      expect(play.isDone, isTrue);
      expect(play.moves, 6);
      expect(play.dipAt(0), same(play));
    });

    test('the pointer lands the full four', () {
      var play = Play.of(Lines.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 20) {
        play = play.dipAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.clashes, isEmpty);
    });

    test('the hopeless line admits it at fourteen dips', () {
      var play = Play.of(Lines.at(4));
      for (var dither = 0; dither < 14; dither++) {
        play = play.dipAt(dither % 5);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable line never gives up', () {
      var play = Play.of(Lines.at(3));
      for (var dither = 0; dither < 14; dither++) {
        play = play.dipAt(0);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands inked home', () {
      final mark =
          Play.standing(Lines.at(2), const [1, 2, 1, 2, 3, 3]);
      expect(mark.isDone, isTrue);
      expect(mark.inked, 6);
    });
  });
}
