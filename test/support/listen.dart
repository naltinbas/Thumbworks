import 'dart:math';
import 'dart:typed_data';

/// A WAV file, read back.
///
/// Written from the specification rather than by undoing what
/// [Render.wrap] does, on purpose: a reader that mirrors the writer agrees
/// with it however wrong they both are. This one checks the fields it is
/// given and complains about the ones it does not understand, which is what a
/// second opinion is for.
class Heard {
  const Heard({
    required this.rate,
    required this.channels,
    required this.bits,
    required this.samples,
  });

  factory Heard.of(Uint8List bytes) {
    final view = ByteData.sublistView(bytes);
    String ascii(int at) =>
        String.fromCharCodes(bytes.sublist(at, at + 4));

    if (ascii(0) != 'RIFF') throw ArgumentError('not a RIFF file');
    if (ascii(8) != 'WAVE') throw ArgumentError('not a WAVE file');
    if (ascii(12) != 'fmt ') throw ArgumentError('no format chunk');

    final format = view.getUint16(20, Endian.little);
    if (format != 1) throw ArgumentError('not uncompressed: $format');

    final channels = view.getUint16(22, Endian.little);
    final rate = view.getUint32(24, Endian.little);
    final bits = view.getUint16(34, Endian.little);
    if (bits != 16) throw ArgumentError('not sixteen bit: $bits');

    if (ascii(36) != 'data') throw ArgumentError('no data chunk');
    final length = view.getUint32(40, Endian.little);
    if (44 + length != bytes.length) {
      throw ArgumentError(
        'the data chunk says $length bytes and the file has ${bytes.length - 44}',
      );
    }

    final samples = Int16List(length ~/ 2);
    for (var i = 0; i < samples.length; i++) {
      samples[i] = view.getInt16(44 + i * 2, Endian.little);
    }

    return Heard(
      rate: rate,
      channels: channels,
      bits: bits,
      samples: samples,
    );
  }

  final int rate;
  final int channels;
  final int bits;
  final Int16List samples;

  double get seconds => samples.length / rate / channels;

  int get peak {
    var most = 0;
    for (final sample in samples) {
      final size = sample.abs();
      if (size > most) most = size;
    }
    return most;
  }

  /// How much of one frequency there is in a window.
  ///
  /// Goertzel: the cheapest way to ask about one frequency rather than all of
  /// them. A whole transform would answer a question nobody asked and take a
  /// hundred times as long — and what a test wants to know is not what is in
  /// the audio, it is whether the note the chart promised is in it.
  double loudnessAt(double hertz, {required double from, required double lasts}) {
    final start = (from * rate).round().clamp(0, samples.length - 1);
    final count = (lasts * rate).round().clamp(1, samples.length - start);

    final turn = 2 * pi * hertz / rate;
    final twice = 2 * cos(turn);
    var back1 = 0.0;
    var back2 = 0.0;

    for (var i = 0; i < count; i++) {
      final now = samples[start + i] / 32768 + twice * back1 - back2;
      back2 = back1;
      back1 = now;
    }

    final power = back1 * back1 + back2 * back2 - twice * back1 * back2;
    return sqrt(power < 0 ? 0 : power) / count;
  }
}
