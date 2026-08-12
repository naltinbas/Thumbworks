import 'package:flutter_test/flutter_test.dart';
import 'package:wickthorn/rope/greens.dart';
import 'package:wickthorn/rope/play.dart';
import 'package:wickthorn/rope/rules.dart';

/// The law of the green, held to.
const fano = [
  (0, 1, 2), (0, 3, 4), (0, 5, 6), (1, 3, 5),
  (1, 4, 6), (2, 3, 6), (2, 4, 5),
];

void main() {
  group('the rules', () {
    test('the ledger counts every pair a rope covers', () {
      final rules = Rules(7);
      final covered = rules.ledger(const [(0, 1, 2), (0, 3, 4)]);
      expect(covered[(0, 1)], 1);
      expect(covered[(1, 2)], 1);
      expect(covered[(0, 3)], 1);
      expect(covered, hasLength(6));
      expect(rules.coveredOnce(const [(0, 1, 2), (0, 3, 4)]), 6);
    });

    test('a doubled pair is a clash', () {
      final rules = Rules(7);
      final ropes = [(0, 1, 2), (0, 1, 3)];
      expect(rules.clashes(ropes), [(0, 1)]);
      expect(rules.closed(ropes), isFalse);
    });

    test('the fano closing closes, to the pair and the lantern', () {
      final rules = Rules(7);
      expect(rules.closed(fano), isTrue);
      expect(rules.standings(fano), everyElement(3));
    });

    test('the search counts the thirty', () {
      expect(Rules(7).closings(const []), 30);
    });

    test('every label\'s ways is what the search finds', () {
      for (final green in Greens.all) {
        expect(
          Rules(green.lanterns).closings(green.given),
          green.ways,
          reason: green.name,
        );
      }
    });

    test('the six lanterns fail by arithmetic and by search', () {
      final rules = Rules(6);
      expect(rules.pairsDivide, isTrue);
      expect(rules.shareDivides, isFalse);
      expect(rules.closings(const []), 0);
      expect(rules.closing(const []), isNull);
    });

    test('a closing extends what is given', () {
      final rules = Rules(7);
      final given = fano.sublist(0, 4);
      final closed = rules.closing(given);
      expect(closed, isNotNull);
      expect(rules.closed(closed!), isTrue);
      for (final rope in given) {
        expect(closed, contains(rope));
      }
    });
  });

  group('the play', () {
    test('three picks string a rope', () {
      var play = Play.of(Greens.at(0));
      play = play.tapAt(0);
      expect(play.picked, [0]);
      expect(play.moves, 0);
      play = play.tapAt(1);
      expect(play.picked, [0, 1]);
      play = play.tapAt(2);
      expect(play.picked, isEmpty);
      expect(play.laid, [(0, 1, 2)]);
      expect(play.moves, 1);
      expect(play.isDone, isTrue);
    });

    test('a second tap unpicks a lantern', () {
      var play = Play.of(Greens.at(3)).tapAt(0).tapAt(1);
      play = play.tapAt(0);
      expect(play.picked, [1]);
      expect(play.moves, 0);
    });

    test('a rope already strung refuses to double', () {
      final green = Greens.at(1);
      var play = Play.of(green);
      // The first given rope is (0, 1, 2): picking it again just
      // drops the picks.
      play = play.tapAt(0).tapAt(1).tapAt(2);
      expect(play.laid, isEmpty);
      expect(play.picked, isEmpty);
      expect(play.moves, 0);
    });

    test('a clash shows itself and blocks the closing', () {
      var play = Play.of(Greens.at(3));
      play = play.tapAt(0).tapAt(1).tapAt(2);
      play = play.tapAt(0).tapAt(1).tapAt(3);
      expect(play.clashes, [(0, 1)]);
      expect(play.isDone, isFalse);
    });

    test('back takes back the last rope, unpicked lets picks go', () {
      var play = Play.of(Greens.at(3));
      play = play.tapAt(0).tapAt(1).tapAt(2);
      expect(play.laid, hasLength(1));
      expect(play.back.laid, isEmpty);
      play = play.tapAt(4).tapAt(5);
      expect(play.unpicked.picked, isEmpty);
      expect(play.unpicked.laid, hasLength(1));
    });

    test('the whole fano strings to a closing', () {
      var play = Play.of(Greens.at(3));
      for (final (a, b, c) in fano) {
        play = play.tapAt(a).tapAt(b).tapAt(c);
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 7);
      expect(play.tapAt(0), same(play));
    });

    test('show me points a rope of a real closing', () {
      final green = Greens.at(2);
      var play = Play.of(green);
      var guard = 0;
      while (!play.isDone && guard++ < 6) {
        final aim = play.next;
        expect(aim, isNotNull);
        final (a, b, c) = aim!;
        play = play.tapAt(a).tapAt(b).tapAt(c);
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 3);
    });

    test('show me goes quiet when a clash stands', () {
      var play = Play.of(Greens.at(3));
      play = play.tapAt(0).tapAt(1).tapAt(2);
      play = play.tapAt(0).tapAt(1).tapAt(3);
      expect(play.clashes, isNotEmpty);
      expect(play.next, isNull);
    });

    test('the hopeless green has nothing to point at', () {
      expect(Play.of(Greens.at(4)).next, isNull);
    });

    test('the hopeless green admits it after twelve ropes', () {
      var play = Play.of(Greens.at(4));
      var rope = 0;
      final triples = [
        for (var a = 0; a < 6; a++)
          for (var b = a + 1; b < 6; b++)
            for (var c = b + 1; c < 6; c++) (a, b, c),
      ];
      while (play.moves < Play.gaveUpAt) {
        expect(play.gaveUp, isFalse);
        final (a, b, c) = triples[rope % triples.length];
        final tried = play.tapAt(a).tapAt(b).tapAt(c);
        // A rope already strung drops the picks instead; take the
        // last one back and string a fresh one to keep moving.
        play = tried.laid.length > play.laid.length ||
                tried.moves > play.moves
            ? tried
            : play.back;
        rope++;
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable green never gives up', () {
      // Twelve distinct ropes, clashes and all: the seven-rope
      // green stays open however long the stringing runs.
      var play = Play.of(Greens.at(3));
      final triples = [
        for (var a = 0; a < 7; a++)
          for (var b = a + 1; b < 7; b++)
            for (var c = b + 1; c < 7; c++) (a, b, c),
      ];
      for (final (a, b, c) in triples.take(12)) {
        play = play.tapAt(a).tapAt(b).tapAt(c);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });
  });
}
