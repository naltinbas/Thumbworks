import 'tune.dart';

/// The pieces, written down.
///
/// Each is a string of bars, sixteen characters to a bar. A digit is a step of
/// the scale, a dash holds the note before it on, and a dot is silence. The
/// notation is here rather than a note list because sixteen characters is a
/// bar somebody can read at a glance and eight Note constructors is not.
///
/// Which lane a note falls in comes out of how high it is: the melody's range
/// is cut into four and the note lands in the quarter it belongs to. Low notes
/// on the left, high notes on the right. It costs nothing and it means the
/// falling notes are the shape of the tune rather than a pattern laid over it.
class Tunes {
  const Tunes._();

  /// Five notes to the octave, so nothing in any of these can sound wrong.
  static const _pentatonic = [0, 3, 5, 7, 10];

  static final all = [first, second, third];

  /// Slow, and mostly on the beat. The one to learn on.
  static final first = _read(
    name: 'Low Water',
    beatsPerMinute: 84,
    root: 261.63,
    bars: [
      '0...2...4...2...',
      '0...2...4...5...',
      '4...2...0...2...',
      '4...5...7.......',
      '5...4...2...0...',
      '2...4...5...4...',
      '2...0...2...4...',
      '0...............',
    ],
  );

  /// Quicker, and the off-beats start to matter.
  static final second = _read(
    name: 'Copper Wire',
    beatsPerMinute: 104,
    root: 293.66,
    bars: [
      '0.2.4.2.5.4.2.0.',
      '0.2.4.5.7.5.4.2.',
      '4.5.7.5.4.2.0.2.',
      '7.5.4.5.7.9.7.5.',
      '4.2.0.2.4.5.4.2.',
      '0.2.4.5.7.9.7.5.',
      '4.5.4.2.0.2.4.5.',
      '7.....5.4.....0.',
      '0.2.4.2.5.4.2.0.',
      '0...............',
    ],
  );

  /// Fast, and it does not let up.
  static final third = _read(
    name: 'Nine Bells',
    beatsPerMinute: 128,
    root: 329.63,
    bars: [
      '0245797502457975',
      '0245797502457975',
      '9755420024579750',
      '7542024579759754',
      '0245797502457975',
      '5424024579420245',
      '9797575424024579',
      '7.5.4.2.0.......',
      '0245797502457975',
      '9755420024579750',
      '0...............',
    ],
  );

  /// Turns bars of characters into notes.
  static Tune _read({
    required String name,
    required double beatsPerMinute,
    required double root,
    required List<String> bars,
  }) {
    final degrees = <({int at, int degree})>[];

    var step = 0;
    for (final bar in bars) {
      assert(bar.length == 16, 'a bar is sixteen steps: "$bar"');
      for (final mark in bar.split('')) {
        if (mark == '-' && degrees.isNotEmpty) {
          // A hold: the note before it rings on.
          degrees.last = degrees.last;
        } else if (mark != '.' && mark != '-') {
          degrees.add((at: step, degree: int.parse(mark)));
        }
        step++;
      }
    }

    // The range, so lanes can be worked out from how high a note is.
    var lowest = 99, highest = 0;
    for (final one in degrees) {
      if (one.degree < lowest) lowest = one.degree;
      if (one.degree > highest) highest = one.degree;
    }
    final span = highest - lowest + 1;

    return Tune(
      name: name,
      beatsPerMinute: beatsPerMinute,
      root: root,
      notes: [
        for (final one in degrees)
          Note(
            at: one.at,
            lane: (((one.degree - lowest) * Tune.lanes) ~/ span)
                .clamp(0, Tune.lanes - 1),
            pitch: _semitonesFor(one.degree),
            lasts: 2,
          ),
      ],
    );
  }

  /// A scale step in semitones, carrying on up the octaves past the fifth.
  static int _semitonesFor(int degree) =>
      _pentatonic[degree % _pentatonic.length] +
      12 * (degree ~/ _pentatonic.length);
}
