import 'package:flutter_test/flutter_test.dart';
import 'package:chimefall/play/beat.dart';

Duration ms(int value) => Duration(milliseconds: value);

void main() {
  group('the beat', () {
    test('reads nothing until the music starts', () {
      final beat = Beat();
      expect(beat.running, isFalse);
      expect(beat.at(ms(500)), 0);
    });

    test('carries the last reading forward with the wall clock', () {
      // The player says a few times a second where it is; a note falls sixty
      // times a second. Everything between readings is this.
      final beat = Beat()..reported(ms(1000), ms(4000));

      expect(beat.at(ms(4000)), closeTo(1.0, 1e-6));
      expect(beat.at(ms(4100)), closeTo(1.1, 1e-6));
      expect(beat.at(ms(4250)), closeTo(1.25, 1e-6));
    });

    test('eases small differences away rather than hopping', () {
      final beat = Beat()..reported(ms(1000), ms(4000));
      // Twenty milliseconds behind where this thought it was.
      beat.reported(ms(1180), ms(4200));

      final now = beat.at(ms(4200));
      expect(now, greaterThan(1.18), reason: 'it moved towards the reading');
      expect(now, lessThan(1.2), reason: 'and not all the way in one go');
    });

    test('believes a big jump at once', () {
      final beat = Beat()..reported(ms(1000), ms(4000));
      // The music was restarted: it is suddenly right back at the beginning.
      beat.reported(ms(0), ms(4200));
      expect(beat.at(ms(4200)), closeTo(0, 1e-6));
    });

    test('stops when the music does', () {
      final beat = Beat()..reported(ms(1000), ms(4000));
      beat.stopped();
      expect(beat.running, isFalse);
      expect(beat.at(ms(9000)), 0);
    });
  });
}
