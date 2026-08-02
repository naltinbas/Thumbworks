import '../tune/tune.dart';

/// How well a note was hit.
enum Judgement {
  /// Dead on.
  perfect,

  /// Close enough.
  good,

  /// Not at all.
  missed;

  int get worth => switch (this) {
        Judgement.perfect => 100,
        Judgement.good => 50,
        Judgement.missed => 0,
      };
}

/// A note, and what became of it.
class Hit {
  const Hit({required this.note, required this.judgement, required this.off});

  final Note note;
  final Judgement judgement;

  /// How far off the tap was, in seconds. Negative is early. Zero for a miss.
  final double off;
}

/// One go at a tune.
///
/// Immutable, and advanced by being told what time it is. Nothing in here
/// reads a clock, which is what lets a test play a whole tune in a millisecond
/// and say exactly what a player who was two hundredths of a second early
/// would have scored.
class Session {
  const Session._({
    required this.tune,
    required this.hits,
    required this.at,
    required this.judged,
    required this.combo,
    required this.best,
    required this.stray,
  });

  factory Session.of(Tune tune) => Session._(
        tune: tune,
        hits: const [],
        at: 0,
        judged: 0,
        combo: 0,
        best: 0,
        stray: 0,
      );

  /// Dead on. A twentieth of a second either way, which is about as close as
  /// a finger on glass gets.
  static const perfectWindow = 0.05;

  /// Close enough. Past this a tap is not about this note at all.
  static const goodWindow = 0.13;

  final Tune tune;

  /// What became of each note, in the order they were judged.
  final List<Hit> hits;

  /// How far into the tune it is, in seconds.
  final double at;

  /// How many notes have been dealt with, counting from the start of the
  /// tune's own order. Everything before this has been hit or missed.
  final int judged;

  final int combo;
  final int best;

  /// Taps that were not near any note. Not punished, but counted: a player
  /// mashing every lane should not come out looking like one who did not.
  final int stray;

  int get score {
    var total = 0;
    var run = 0;
    for (final hit in hits) {
      if (hit.judgement == Judgement.missed) {
        run = 0;
        continue;
      }
      run++;
      // The multiplier stops climbing at four, so a long tune is not decided
      // entirely by whether somebody dropped one note early on.
      final times = run < 10 ? 1 : (run < 25 ? 2 : (run < 50 ? 3 : 4));
      total += hit.judgement.worth * times;
    }
    return total;
  }

  int countOf(Judgement judgement) =>
      hits.where((hit) => hit.judgement == judgement).length;

  bool get isOver => at >= tune.seconds;

  /// Every note not yet judged, in order.
  List<Note> get waiting => tune.inOrder.sublist(judged);

  /// The most anybody could score, for the bar at the end.
  int get possible {
    var total = 0;
    var run = 0;
    for (var i = 0; i < tune.count; i++) {
      run++;
      final times = run < 10 ? 1 : (run < 25 ? 2 : (run < 50 ? 3 : 4));
      total += Judgement.perfect.worth * times;
    }
    return total;
  }

  /// The session at a later moment, with anything whose window has closed
  /// marked missed.
  Session seenTo(double when) {
    var session = _copy(at: when);
    while (session.judged < session.tune.count) {
      final note = session.tune.inOrder[session.judged];
      if (note.secondsAt(tune.beatsPerMinute) + goodWindow >= when) break;
      session = session._took(note, Judgement.missed, 0);
    }
    return session;
  }

  /// The session after a tap in a lane.
  ///
  /// The note it counts for is the nearest one in that lane still waiting,
  /// which is the only reading of a tap that is ever right: a player aiming at
  /// a note is not aiming at the one behind it.
  Session tapped(int lane, double when) {
    Note? nearest;
    var closest = double.infinity;

    for (final note in waiting) {
      if (note.lane != lane) continue;
      final off = when - note.secondsAt(tune.beatsPerMinute);
      if (off.abs() > goodWindow) continue;
      if (off.abs() < closest) {
        closest = off.abs();
        nearest = note;
      }
    }

    if (nearest == null) {
      return _copy(at: when, stray: stray + 1);
    }

    final off = when - nearest.secondsAt(tune.beatsPerMinute);
    final judgement =
        off.abs() <= perfectWindow ? Judgement.perfect : Judgement.good;
    return _copy(at: when)._took(nearest, judgement, off);
  }

  /// Marks a note dealt with.
  ///
  /// Notes are judged in the order they sound, so hitting one late leaves the
  /// ones before it missed — which is right: they were.
  Session _took(Note note, Judgement judgement, double off) {
    final upTo = tune.inOrder.indexOf(note);
    final taken = [...hits];
    var run = combo;
    var most = best;

    for (var i = judged; i < upTo; i++) {
      taken.add(Hit(note: tune.inOrder[i], judgement: Judgement.missed, off: 0));
      run = 0;
    }
    taken.add(Hit(note: note, judgement: judgement, off: off));
    if (judgement == Judgement.missed) {
      run = 0;
    } else {
      run++;
      if (run > most) most = run;
    }

    return _copy(hits: taken, judged: upTo + 1, combo: run, best: most);
  }

  Session _copy({
    List<Hit>? hits,
    double? at,
    int? judged,
    int? combo,
    int? best,
    int? stray,
  }) =>
      Session._(
        tune: tune,
        hits: hits ?? this.hits,
        at: at ?? this.at,
        judged: judged ?? this.judged,
        combo: combo ?? this.combo,
        best: best ?? this.best,
        stray: stray ?? this.stray,
      );
}
