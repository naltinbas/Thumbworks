import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:chimefall/play/session.dart';
import 'package:chimefall/tune/tune.dart';
import 'package:chimefall/tune/tunes.dart';

/// Plays a whole tune, tapping every note [off] seconds from dead on.
Session playAll(Tune tune, {double off = 0}) {
  var session = Session.of(tune);
  for (final note in tune.inOrder) {
    final when = note.secondsAt(tune.beatsPerMinute) + off;
    session = session.seenTo(when).tapped(note.lane, when);
  }
  return session.seenTo(tune.seconds);
}

void main() {
  final tune = Tunes.first;
  double whenOf(Note note) => note.secondsAt(tune.beatsPerMinute);

  group('judging a tap', () {
    test('dead on is perfect', () {
      final note = tune.inOrder.first;
      final session = Session.of(tune).tapped(note.lane, whenOf(note));

      expect(session.hits, hasLength(1));
      expect(session.hits.first.judgement, Judgement.perfect);
      expect(session.hits.first.off, closeTo(0, 1e-9));
      expect(session.combo, 1);
    });

    test('a little off is good', () {
      final note = tune.inOrder.first;
      final late = whenOf(note) + Session.perfectWindow + 0.02;
      final session = Session.of(tune).tapped(note.lane, late);

      expect(session.hits.first.judgement, Judgement.good);
      expect(session.hits.first.off, greaterThan(0), reason: 'it was late');
    });

    test('early counts the same as late', () {
      final note = tune.inOrder.first;
      final early = Session.of(tune).tapped(note.lane, whenOf(note) - 0.08);
      final late = Session.of(tune).tapped(note.lane, whenOf(note) + 0.08);
      expect(early.hits.first.judgement, late.hits.first.judgement);
      expect(early.hits.first.off, -late.hits.first.off);
    });

    test('far off is not about that note at all', () {
      final note = tune.inOrder.first;
      final session = Session.of(tune).tapped(note.lane, whenOf(note) + 0.4);

      expect(session.hits, isEmpty);
      expect(session.stray, 1, reason: 'it was counted, not punished');
      expect(session.combo, 0);
    });

    test('in the wrong lane hits nothing', () {
      final note = tune.inOrder.first;
      final wrong = (note.lane + 1) % Tune.lanes;
      final session = Session.of(tune).tapped(wrong, whenOf(note));

      expect(session.hits, isEmpty);
      expect(session.stray, 1);
    });

    test('counts for the nearest note in the lane, not the next one', () {
      // Two notes in one lane close together: a tap by the second must not be
      // read as a very late hit on the first.
      final lane = tune.inOrder.first.lane;
      final inLane = tune.inOrder.where((note) => note.lane == lane).toList();
      expect(inLane.length, greaterThan(1));

      final second = inLane[1];
      final session = Session.of(tune).tapped(lane, whenOf(second));
      expect(session.hits.last.note.at, second.at);
      expect(session.hits.last.judgement, Judgement.perfect);
    });
  });

  group('a note nobody hits', () {
    test('is missed once its window has closed, and not before', () {
      final note = tune.inOrder.first;
      final justInTime = Session.of(tune)
          .seenTo(whenOf(note) + Session.goodWindow - 0.01);
      expect(justInTime.hits, isEmpty, reason: 'it is still hittable');

      final gone = justInTime.seenTo(whenOf(note) + Session.goodWindow + 0.01);
      expect(gone.hits, hasLength(1));
      expect(gone.hits.first.judgement, Judgement.missed);
      expect(gone.combo, 0);
    });

    test('breaks the run', () {
      var session = Session.of(tune);
      final notes = tune.inOrder;

      for (var i = 0; i < 3; i++) {
        final when = whenOf(notes[i]);
        session = session.seenTo(when).tapped(notes[i].lane, when);
      }
      expect(session.combo, 3);

      // Skip one, then carry on.
      final after = whenOf(notes[4]);
      session = session.seenTo(after).tapped(notes[4].lane, after);
      expect(session.combo, 1, reason: 'the run started again');
      expect(session.best, 3, reason: 'and the longest one is remembered');
      expect(session.countOf(Judgement.missed), 1);
    });
  });

  group('a whole go', () {
    test('played perfectly scores everything there is', () {
      final done = playAll(tune);
      expect(done.countOf(Judgement.perfect), tune.count);
      expect(done.countOf(Judgement.missed), 0);
      expect(done.score, done.possible);
      expect(done.best, tune.count);
    });

    test('played a little late scores less, and misses nothing', () {
      final done = playAll(tune, off: 0.09);
      expect(done.countOf(Judgement.good), tune.count);
      expect(done.countOf(Judgement.missed), 0);
      expect(done.score, lessThan(done.possible));
      expect(done.score, greaterThan(done.possible ~/ 3));
    });

    test('played not at all misses everything and scores nothing', () {
      final done = Session.of(tune).seenTo(tune.seconds);
      expect(done.countOf(Judgement.missed), tune.count);
      expect(done.score, 0);
      expect(done.isOver, isTrue);
    });

    test('mashed scores worse than played', () {
      // Every lane tapped on every sixteenth, all the way through. It gets a
      // fair number of notes by luck, and it must not come out looking like
      // somebody who was listening.
      final random = Random(1);
      var mashed = Session.of(tune);
      for (var step = 0.0; step < tune.seconds; step += 0.1) {
        mashed = mashed.seenTo(step).tapped(random.nextInt(Tune.lanes), step);
      }
      mashed = mashed.seenTo(tune.seconds);

      expect(mashed.score, lessThan(playAll(tune).score ~/ 2));
      expect(mashed.stray, greaterThan(tune.count));
    });

    test('the longest run is worth more than the same notes scattered', () {
      // Fifty in a row beats fifty spread out, which is what makes a rhythm
      // game about keeping going rather than about hitting things.
      final together = playAll(Tunes.third);

      var scattered = Session.of(Tunes.third);
      final notes = Tunes.third.inOrder;
      for (var i = 0; i < notes.length; i++) {
        final when = notes[i].secondsAt(Tunes.third.beatsPerMinute);
        scattered = scattered.seenTo(when);
        if (i.isEven) scattered = scattered.tapped(notes[i].lane, when);
      }
      scattered = scattered.seenTo(Tunes.third.seconds);

      expect(scattered.countOf(Judgement.perfect) * 2,
          closeTo(together.countOf(Judgement.perfect), 2));
      expect(scattered.score, lessThan(together.score ~/ 2),
          reason: 'half the notes should be worth less than half the score');
    });
  });
}
