import 'package:flutter_test/flutter_test.dart';
import 'package:chasegarth/forme/chase.dart';
import 'package:chasegarth/forme/chases.dart';
import 'package:chasegarth/forme/fewest.dart';
import 'package:chasegarth/forme/parity.dart';
import 'package:chasegarth/forme/play.dart';

void main() {
  group('the chase', () {
    final chase = Chase(name: 'x', wide: 3, tall: 2, reading: 'QUOIN');

    test('reads the frame straight through', () {
      expect(chase.reads(chase.locked), 'QUOIN ');
      expect(chase.reads(const [4, -1, 0, 3, 1, 2]), 'N QIUO');
    });

    test('knows which cells are beside the empty one', () {
      // The corner has two, the middle of an edge three.
      expect(chase.beside(0), [1, 3]);
      expect(chase.beside(1), [0, 2, 4]);
      expect(chase.beside(4), [3, 5, 1]);
    });

    test('and when the type is locked', () {
      expect(chase.isLocked(chase.locked), isTrue);
      expect(chase.isLocked(const [0, 1, 2, 3, -1, 4]), isFalse);
    });
  });

  group('the parity', () {
    test('a sideways slide changes no pairs at all', () {
      final before = [0, -1, 1, 2, 3, 4];
      final after = Slides.slide(before, 2);
      expect(Parity.outOfOrder(before).length,
          Parity.outOfOrder(after).length);
    });

    test('the thing that never changes really never changes', () {
      // Walk a few hundred slides at random over each shape and watch it.
      for (final (wide, tall, reading) in const [
        (2, 2, 'INK'),
        (3, 2, 'QUOIN'),
        (2, 3, 'FLONG'),
        (3, 3, 'MATRICES'),
      ]) {
        final chase =
            Chase(name: 'x', wide: wide, tall: tall, reading: reading);
        var stands = chase.locked;
        final even = Parity.isEven(chase, stands);
        var seed = 12345;
        for (var go = 0; go < 300; go++) {
          final beside = chase.beside(stands.indexOf(-1));
          seed = (seed * 1103515245 + 12345) & 0x7fffffff;
          stands = Slides.slide(stands, beside[seed % beside.length]);
          expect(Parity.isEven(chase, stands), even,
              reason: '$reading after ${go + 1} slides');
        }
      }
    });

    test('agrees with a full walk on every arrangement of every shape', () {
      // The parity is arithmetic and the walk looks at everything. They have
      // to say the same thing about all 362,880 arrangements of the 3 by 3,
      // and the smaller shapes besides. This is the test that caught the
      // parity being wrong for frames an odd number of cells wide.
      for (final (wide, tall, reading) in const [
        (2, 2, 'INK'),
        (3, 2, 'QUOIN'),
        (2, 3, 'FLONG'),
        (3, 3, 'MATRICES'),
      ]) {
        final chase =
            Chase(name: 'x', wide: wide, tall: tall, reading: reading);
        final (agreed, disagreed) = Slides(chase).againstParity();
        expect(disagreed, 0, reason: '$wide by $tall');
        expect(agreed, Slides(chase).everyArrangement, reason: '$wide by $tall');
      }
    });

    test('exactly half of everything can be locked', () {
      for (final (wide, tall, reading) in const [
        (2, 2, 'INK'),
        (3, 2, 'QUOIN'),
        (4, 2, 'JUSTIFY'),
        (3, 3, 'MATRICES'),
      ]) {
        final chase =
            Chase(name: 'x', wide: wide, tall: tall, reading: reading);
        final slides = Slides(chase);
        expect(slides.reached * 2, slides.everyArrangement,
            reason: '$wide by $tall');
      }
    });
  });

  group('the table of distances', () {
    test('every distance is a real shortest way', () {
      // From any arrangement, one neighbour is exactly one nearer, and none
      // is more than one nearer. Checked over every arrangement of the 3 by 2.
      final chase = Chase(name: 'x', wide: 3, tall: 2, reading: 'QUOIN');
      final slides = Slides(chase);
      for (var far = 1; far <= 21; far++) {
        for (final stands in slides.allAt(far)) {
          final empty = stands.indexOf(-1);
          var nearer = 0;
          for (final cell in chase.beside(empty)) {
            final there = slides.from(Slides.slide(stands, cell))!;
            expect((there - far).abs(), lessThanOrEqualTo(1));
            if (there == far - 1) nearer++;
          }
          expect(nearer, greaterThan(0));
        }
      }
    });

    test('and the next slide it points at really is one nearer', () {
      final chase = Chase(name: 'x', wide: 3, tall: 2, reading: 'QUOIN');
      final slides = Slides(chase);
      final start = [2, 4, 3, -1, 1, 0];
      var stands = start;
      var far = slides.from(stands)!;
      while (far > 0) {
        final cell = slides.nextFrom(stands)!;
        stands = Slides.slide(stands, cell);
        expect(slides.from(stands), far - 1);
        far--;
      }
      expect(chase.isLocked(stands), isTrue);
    });
  });

  group('every forme that ships', () {
    setUp(Formes.forget);

    for (var number = 0; number < Formes.count; number++) {
      final forme = Formes.at(number);

      test('${forme.name} starts where the label says', () {
        final from = Formes.slidesFor(number).from(forme.start);
        if (forme.dropped) {
          expect(from, isNull);
        } else {
          expect(from, forme.fewest);
        }
      });

      test('${forme.name} reads with no letter twice', () {
        final letters = forme.chase.reading.split('');
        expect(letters.toSet(), hasLength(letters.length));
        expect(forme.chase.reading.length, forme.chase.cells - 1);
      });
    }

    test('Matrices starts at the worst arrangement there is', () {
      final matrices = Formes.all.indexWhere((forme) => forme.name == 'Matrices');
      final slides = Formes.slidesFor(matrices);
      final (_, worst) = slides.furthest;
      expect(Formes.at(matrices).fewest, worst);
    });

    test('the dropped forme is dropped and the rest are not', () {
      expect(Formes.all.where((forme) => forme.dropped), hasLength(1));
    });
  });

  group('a forme on the bench', () {
    late Play play;

    setUp(() {
      Formes.forget();
      play = Play.of(Formes.at(1), Formes.slidesFor(1));
    });

    test('starts as it was handed over', () {
      expect(play.made, 0);
      expect(play.stands, Formes.at(1).start);
      expect(play.couldFinishIn, Formes.at(1).fewest);
      expect(play.canBeLocked, isTrue);
    });

    test('a letter beside the empty cell slides into it', () {
      final cell = play.canSlide.first;
      final sort = play.sortIn(cell);
      play = play.slide(cell);
      expect(play.sortIn(cell), -1);
      expect(play.stands.indexOf(sort), isNot(-1));
      expect(play.made, 1);
    });

    test('a letter away from it does not', () {
      final away = [
        for (var cell = 0; cell < play.chase.cells; cell++)
          if (!play.canSlide.contains(cell) && play.sortIn(cell) >= 0) cell,
      ].first;
      expect(identical(play.slide(away), play), isTrue);
    });

    test('a wrong slide costs, and the game knows at once', () {
      // Any slide that does not bring the distance down by one puts the total
      // up by two, since it has to be undone.
      final before = play.couldFinishIn!;
      final good = play.next!;
      final bad = play.canSlide.firstWhere((cell) => cell != good);
      play = play.slide(bad);
      expect(play.couldFinishIn, before + 2);
    });

    test('again puts the type back as it was', () {
      play = play.slide(play.canSlide.first).again;
      expect(play.made, 0);
      expect(play.stands, Formes.at(1).start);
    });

    test('following the table locks every forme in the fewest slides', () {
      for (var number = 0; number < Formes.count; number++) {
        final forme = Formes.at(number);
        var walk = Play.of(forme, Formes.slidesFor(number));
        if (forme.dropped) {
          expect(walk.canBeLocked, isFalse);
          expect(walk.next, isNull);
          walk = walk.mend();
          expect(walk.mended, isTrue);
          expect(walk.canBeLocked, isTrue);
        }
        var guard = 0;
        while (!walk.isLocked) {
          if (guard++ > 40) fail('${forme.name} never locked');
          walk = walk.slide(walk.next!);
        }
        expect(walk.made, forme.fewest, reason: forme.name);
        expect(walk.isFewest, isTrue, reason: forme.name);
        expect(walk.reads, '${forme.chase.reading} ', reason: forme.name);
      }
    });

    test('the mend does nothing on a forme that was never dropped', () {
      expect(identical(play.mend(), play), isTrue);
    });
  });
}
