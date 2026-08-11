import 'package:flutter_test/flutter_test.dart';
import 'package:dipthorne/ring/fewest.dart';
import 'package:dipthorne/ring/play.dart';
import 'package:dipthorne/ring/rings.dart';

void main() {
  group('the count and the reckoning', () {
    test('agree on every ring to a hundred and twenty, every rhyme to '
        'twelve', () {
      // The anchor. The count stands the ring up and runs it; the
      // reckoning climbs the recurrence and never sees a ring at all.
      for (var children = 1; children <= 120; children++) {
        for (var beats = 1; beats <= 12; beats++) {
          expect(Dips.byCount(children, beats),
              Dips.byReckoning(children, beats),
              reason: '$children children, $beats beats');
        }
      }
    });

    test('and the binary turn joins them on every two-beat ring to five '
        'hundred', () {
      for (var children = 1; children <= 500; children++) {
        expect(Dips.byBinaryTurn(children), Dips.byReckoning(children, 2),
            reason: '$children children');
      }
    });

    test('the dip stone seat is safe exactly on the powers of two', () {
      for (var children = 1; children <= 64; children++) {
        final power = children & (children - 1) == 0;
        expect(Dips.byReckoning(children, 2) == 1, power,
            reason: '$children children');
      }
    });

    test('the count sends out who it sends out', () {
      expect(Dips.outs(8, 2), [2, 4, 6, 8, 3, 7, 5]);
      final out = Dips.outs(13, 2);
      expect(out, hasLength(12));
      expect(out.contains(11), isFalse);
    });
  });

  group('every ring that ships', () {
    for (var number = 0; number < Rings.count; number++) {
      final ring = Rings.at(number);

      test('${ring.name} says what the count and the reckoning say', () {
        expect(Dips.byCount(ring.children, ring.beats), ring.safe);
        expect(Dips.byReckoning(ring.children, ring.beats), ring.safe);
      });
    }

    test('ip dip is the boundary: the dip stone seat itself', () {
      expect(Rings.at(0).children & (Rings.at(0).children - 1), 0);
      expect(Rings.at(0).safe, 1);
    });

    test('the rhymes carry their beats', () {
      expect(Rings.at(0).beats, 2);
      expect(Rings.at(3).beats, 7);
      expect(Rings.at(4).beats, 5);
    });
  });

  group('a dip in play', () {
    test('starts with everyone in and nobody chosen', () {
      final play = Play.of(Rings.at(1));
      expect(play.hasChosen, isFalse);
      expect(play.standing, hasLength(13));
      expect(play.isOver, isFalse);
      expect(play.landsOn, isNull);
    });

    test('a seat is taken before the rhyme starts, and only then', () {
      var play = Play.of(Rings.at(1)).choose(11);
      expect(play.chosen, 11);
      play = play.step();
      expect(identical(play.choose(5), play), isTrue);
    });

    test('the chant lands where it says it will', () {
      var play = Play.of(Rings.at(1)).choose(11);
      while (!play.isOver) {
        final lands = play.landsOn;
        play = play.step();
        expect(play.out.last, lands);
      }
    });

    test('the count in play sends out what the count alone says', () {
      var play = Play.of(Rings.at(2)).choose(9);
      while (!play.isOver) {
        play = play.step();
      }
      expect(play.out, Dips.outs(20, 2).sublist(0, play.out.length));
    });

    test('standing in the safe seat survives the whole rhyme', () {
      for (var number = 0; number < Rings.count; number++) {
        final ring = Rings.at(number);
        var play = Play.of(ring).choose(ring.safe);
        var guard = 0;
        while (!play.isOver) {
          if (guard++ > ring.children) fail('${ring.name} never ended');
          play = play.step();
        }
        expect(play.won, isTrue, reason: ring.name);
        expect(play.standing.single, ring.safe, reason: ring.name);
      }
    });

    test('standing anywhere else, the rhyme finds you', () {
      for (var number = 0; number < Rings.count; number++) {
        final ring = Rings.at(number);
        for (var seat = 1; seat <= ring.children; seat++) {
          if (seat == ring.safe) continue;
          var play = Play.of(ring).choose(seat);
          var guard = 0;
          while (!play.isOver) {
            if (guard++ > ring.children) fail('${ring.name} never ended');
            play = play.step();
          }
          expect(play.won, isFalse, reason: '${ring.name} seat $seat');
          expect(play.out.contains(seat), isTrue,
              reason: '${ring.name} seat $seat');
        }
      }
    });

    test('the play asks the reckoning for the safe seat', () {
      expect(Play.of(Rings.at(1)).safe, 11);
      expect(Play.of(Rings.at(3)).safe, 9);
    });
  });
}
