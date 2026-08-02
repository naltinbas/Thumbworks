/// One note: when it sounds, which lane it falls in, and what it sounds like.
///
/// The same object is both the music and the chart. That is the whole idea of
/// this game: a rhythm game whose audio and whose falling notes come from two
/// different files has two things that can drift apart, and the drift is
/// exactly what makes one unplayable. Here there is nothing to keep in step,
/// because there is only one list.
class Note {
  const Note({
    required this.at,
    required this.lane,
    required this.pitch,
    this.lasts = 1,
  });

  /// Which sixteenth of a beat it lands on, counting from the start.
  final int at;

  /// Which lane it falls in.
  final int lane;

  /// Semitones above the tune's root. Zero is the root itself.
  final int pitch;

  /// How many sixteenths it rings for.
  final int lasts;

  /// When it sounds, in seconds, at a given tempo.
  double secondsAt(double beatsPerMinute) => at * _stepSeconds(beatsPerMinute);

  double lengthAt(double beatsPerMinute) =>
      lasts * _stepSeconds(beatsPerMinute);

  /// A sixteenth of a beat, in seconds.
  static double _stepSeconds(double beatsPerMinute) =>
      60 / beatsPerMinute / 4;

  @override
  String toString() => 'note($at, lane $lane, +$pitch)';
}

/// A piece: a tempo, a key, and the notes.
class Tune {
  const Tune({
    required this.name,
    required this.beatsPerMinute,
    required this.root,
    required this.notes,
  });

  final String name;
  final double beatsPerMinute;

  /// The frequency of pitch zero, in hertz.
  final double root;

  final List<Note> notes;

  static const lanes = 4;

  /// How long the whole thing lasts, in seconds, with a little room after the
  /// last note for it to ring out.
  double get seconds {
    var last = 0.0;
    for (final note in notes) {
      final ends = note.secondsAt(beatsPerMinute) + note.lengthAt(beatsPerMinute);
      if (ends > last) last = ends;
    }
    return last + 1.2;
  }

  /// Every note, in the order they sound.
  List<Note> get inOrder => [...notes]..sort((a, b) => a.at - b.at);

  /// How many notes there are, which is the most anybody can hit.
  int get count => notes.length;
}

/// The frequency of a pitch, in hertz.
///
/// Twelve semitones to an octave and each one the twelfth root of two above
/// the last, which is the only thing in this file that is not a choice.
double hertzOf(double root, int semitones) =>
    root * _pow(1.0594630943592953, semitones);

double _pow(double base, int times) {
  var out = 1.0;
  for (var i = 0; i < times.abs(); i++) {
    out *= base;
  }
  return times < 0 ? 1 / out : out;
}
