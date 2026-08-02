import 'dart:math';
import 'dart:typed_data';

import 'tune.dart';

/// Turns a tune into sound.
///
/// The audio is made from the same note list the falling notes come from, so
/// there is nothing to keep in step. A rhythm game whose music is one file and
/// whose chart is another has two things that can drift, and the drift is
/// exactly what makes one unplayable.
///
/// The sound itself is a struck chime: three sine partials, the higher ones
/// quieter and dying faster, over an envelope that rises in a few
/// milliseconds and falls away. That is most of what a struck metal bar does,
/// and it is four lines of arithmetic rather than a licence and a download.
class Render {
  const Render._();

  static const rate = 44100;

  /// How loud one note is at its peak, out of one.
  static const _peak = 0.28;

  /// The partials of a chime: how far above the note, and how loud.
  ///
  /// Not a harmonic series. A struck bar rings at ratios that are not whole
  /// numbers, which is why a bell sounds like a bell and a plucked string does
  /// not — 2.76 and 5.4 are close enough to the real thing to be recognisable
  /// and simple enough to write down.
  static const _partials = [
    (times: 1.0, loud: 1.0, dies: 3.4),
    (times: 2.76, loud: 0.42, dies: 6.0),
    (times: 5.4, loud: 0.18, dies: 9.5),
  ];

  /// The whole tune, as 16-bit mono samples.
  static Int16List samples(Tune tune) {
    final total = (tune.seconds * rate).ceil();
    final mix = Float64List(total);

    for (final note in tune.notes) {
      final from = (note.secondsAt(tune.beatsPerMinute) * rate).round();
      final hertz = hertzOf(tune.root, note.pitch);

      // A note rings for as long as it takes to fade out, not for the length
      // it was written as: a chime that stopped dead on the next note would
      // sound like a switch rather than a bell.
      final rings = (2.2 * rate).round();
      for (var i = 0; i < rings; i++) {
        final at = from + i;
        if (at >= total) break;
        final t = i / rate;

        // A few milliseconds of attack, so nothing clicks.
        final rise = t < 0.004 ? t / 0.004 : 1.0;
        var value = 0.0;
        for (final partial in _partials) {
          value += sin(2 * pi * hertz * partial.times * t) *
              partial.loud *
              exp(-t * partial.dies);
        }
        mix[at] += value * rise * _peak;
      }
    }

    final out = Int16List(total);
    for (var i = 0; i < total; i++) {
      // Clipped rather than normalised. Normalising would make a tune with one
      // loud moment quiet everywhere else, and these are all written to sit
      // well under the ceiling anyway.
      final value = mix[i].clamp(-1.0, 1.0);
      out[i] = (value * 32767).round();
    }
    return out;
  }

  /// The samples wrapped in a WAV header: 16-bit, mono, 44.1k.
  static Uint8List wav(Tune tune) => wrap(samples(tune));

  /// Wraps samples in the smallest WAV header there is.
  static Uint8List wrap(Int16List samples) {
    final payload = samples.buffer.asUint8List(
      samples.offsetInBytes,
      samples.lengthInBytes,
    );
    final out = BytesBuilder();

    void ascii(String text) => out.add(text.codeUnits);
    void u32(int value) => out.add(
          Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.little),
        );
    void u16(int value) => out.add(
          Uint8List(2)..buffer.asByteData().setUint16(0, value, Endian.little),
        );

    ascii('RIFF');
    u32(36 + payload.length);
    ascii('WAVE');
    ascii('fmt ');
    u32(16);
    u16(1); // uncompressed
    u16(1); // mono
    u32(rate);
    u32(rate * 2); // bytes a second
    u16(2); // bytes a sample
    u16(16); // bits a sample
    ascii('data');
    u32(payload.length);
    out.add(payload);

    return out.toBytes();
  }
}
