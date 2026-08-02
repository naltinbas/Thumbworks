// This is a command line tool whose whole job is to write files and say so.
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:chimefall/tune/render.dart';
import 'package:chimefall/tune/tunes.dart';

/// Renders every tune to a WAV in assets/.
///
/// Run with: dart run tool/build_audio.dart
///
/// The audio is generated rather than licensed, from the same note list the
/// falling notes come from. Doing it here rather than on the phone is only
/// about time: a two minute tune is five million samples and three sine waves
/// each, which is a second of work nobody should wait through on a launch.
void main() {
  for (final tune in Tunes.all) {
    final bytes = Render.wav(tune);
    final name = tune.name.toLowerCase().replaceAll(' ', '-');
    File('assets/$name.wav').writeAsBytesSync(bytes);
    print('${tune.name.padRight(12)} '
        '${tune.count.toString().padLeft(4)} notes  '
        '${tune.seconds.toStringAsFixed(1)}s  '
        '${(bytes.length / 1024).round()}k  '
        'assets/$name.wav');
  }
}
