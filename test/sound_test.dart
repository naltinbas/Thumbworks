import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:chimefall/tune/render.dart';
import 'package:chimefall/tune/tune.dart';
import 'package:chimefall/tune/tunes.dart';

import 'support/listen.dart';

void main() {
  group('a tune', () {
    test('reads back the bars it was written as', () {
      final tune = Tunes.first;
      expect(tune.count, greaterThan(20));
      expect(tune.notes.first.at, 0, reason: 'it starts on the beat');
      expect(tune.seconds, greaterThan(15));

      for (final note in tune.notes) {
        expect(note.lane, inInclusiveRange(0, Tune.lanes - 1));
        expect(note.at, greaterThanOrEqualTo(0));
      }
    });

    test('puts low notes on the left and high ones on the right', () {
      // The lane is the shape of the melody rather than a pattern laid over
      // it, so the lowest note in a tune must be further left than the
      // highest.
      for (final tune in Tunes.all) {
        final lowest = tune.notes.reduce((a, b) => a.pitch <= b.pitch ? a : b);
        final highest = tune.notes.reduce((a, b) => a.pitch >= b.pitch ? a : b);
        expect(lowest.lane, lessThan(highest.lane), reason: tune.name);
      }
    });

    test('gets busier from the first to the last', () {
      double perSecond(Tune tune) => tune.count / tune.seconds;
      expect(perSecond(Tunes.second), greaterThan(perSecond(Tunes.first)));
      expect(perSecond(Tunes.third), greaterThan(perSecond(Tunes.second)));
    });

    test('a semitone is the twelfth root of two', () {
      expect(hertzOf(440, 0), closeTo(440, 0.001));
      expect(hertzOf(440, 12), closeTo(880, 0.01));
      expect(hertzOf(440, 7), closeTo(659.26, 0.1), reason: 'a fifth above A');
      expect(hertzOf(440, -12), closeTo(220, 0.01));
    });
  });

  group('the sound it makes', () {
    test('is a WAV a reader written from the specification accepts', () {
      // The reader in test/support was written from the format rather than by
      // undoing the writer, so this is two opinions agreeing rather than one
      // opinion twice.
      final heard = Heard.of(Render.wav(Tunes.first));

      expect(heard.rate, 44100);
      expect(heard.channels, 1);
      expect(heard.bits, 16);
      expect(heard.seconds, closeTo(Tunes.first.seconds, 0.05));
    });

    test('is loud enough to hear and never clips', () {
      for (final tune in Tunes.all) {
        final heard = Heard.of(Render.wav(tune));
        expect(heard.peak, greaterThan(8000),
            reason: '${tune.name} is too quiet to be a game');
        expect(heard.peak, lessThan(32767),
            reason: '${tune.name} is squared off at the top');
      }
    });

    test('starts and ends in silence', () {
      // The first note is on the beat, so the very first samples are the
      // attack rather than nothing; what matters is that the file does not
      // begin part way through a sound, and that it rings out rather than
      // being cut off.
      final heard = Heard.of(Render.wav(Tunes.first));
      expect(heard.samples.first.abs(), lessThan(600));
      expect(heard.samples.last.abs(), lessThan(600),
          reason: 'the last note is cut off rather than allowed to fade');
    });

    test('has every note in it, at the pitch and the moment the chart says',
        () {
      // The claim this whole game rests on: the falling notes and the sound
      // are the same list, so the sound must actually contain them.
      //
      // Asked one frequency at a time rather than by looking for onsets. An
      // onset detector finds nothing in a dense passage, because the sound
      // never drops between notes — but a note's own pitch appearing where it
      // was not before is plain however busy the music is.
      for (final tune in Tunes.all) {
        final heard = Heard.of(Render.wav(tune));
        var checked = 0;

        for (final note in tune.inOrder) {
          final at = note.secondsAt(tune.beatsPerMinute);
          if (at < 0.5) continue;

          // Skip a note whose pitch was already ringing: it is already in the
          // sound, so asking whether it arrived is asking nothing.
          final sameLately = tune.notes.any((other) =>
              other.pitch == note.pitch &&
              other.at < note.at &&
              at - other.secondsAt(tune.beatsPerMinute) < 1.5);
          if (sameLately) continue;

          final hertz = hertzOf(tune.root, note.pitch);
          final before = heard.loudnessAt(hertz, from: at - 0.09, lasts: 0.08);
          final after = heard.loudnessAt(hertz, from: at + 0.01, lasts: 0.08);

          expect(after, greaterThan(before * 1.5),
              reason: '${tune.name}: $note at ${at.toStringAsFixed(2)}s '
                  'is not in the sound (before $before, after $after)');
          checked++;
        }

        expect(checked, greaterThan(8),
            reason: '${tune.name}: too few notes were worth checking');
      }
    });

    test('does not contain a note the chart never asked for', () {
      // The other way round. A frequency two semitones off every note in the
      // tune should be quiet all the way through — if it is not, the
      // synthesiser is putting something in the sound that nothing on screen
      // will ever fall for.
      final tune = Tunes.first;
      final heard = Heard.of(Render.wav(tune));
      final used = tune.notes.map((note) => note.pitch).toSet();
      final absent = List.generate(24, (i) => i - 12)
          .firstWhere((pitch) => !used.contains(pitch) &&
              !used.contains(pitch - 1) &&
              !used.contains(pitch + 1));

      final wrong = heard.loudnessAt(
        hertzOf(tune.root, absent),
        from: 0,
        lasts: tune.seconds,
      );
      final right = heard.loudnessAt(
        hertzOf(tune.root, tune.notes.first.pitch),
        from: 0,
        lasts: tune.seconds,
      );
      expect(wrong, lessThan(right * 0.5),
          reason: 'a pitch nothing plays is as loud as one that does');
    });
  });

  group('the files that ship', () {
    test('are the tunes, rendered', () {
      // What is in assets/ has to be what the code makes now, not what it made
      // when somebody last remembered to run the tool.
      for (final tune in Tunes.all) {
        final name = tune.name.toLowerCase().replaceAll(' ', '-');
        final file = File('assets/$name.wav');
        expect(file.existsSync(), isTrue,
            reason: 'assets/$name.wav is missing — run make audio');

        final shipped = Heard.of(file.readAsBytesSync());
        final fresh = Heard.of(Render.wav(tune));
        expect(shipped.samples.length, fresh.samples.length,
            reason: 'assets/$name.wav is stale — run make audio');
        expect(shipped.peak, fresh.peak);
      }
    });
  });
}
