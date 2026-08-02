import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/trail.dart';

void main() {
  group('the trail', () {
    test('keeps the points in the order they were flown', () {
      final trail = Trail(capacity: 4);
      for (var i = 0; i < 3; i++) {
        trail.add(Vec(i.toDouble(), 0));
      }
      expect(trail.points.map((p) => p.x), [0, 1, 2]);
    });

    test('forgets the oldest point once it is full', () {
      final trail = Trail(capacity: 3);
      for (var i = 0; i < 5; i++) {
        trail.add(Vec(i.toDouble(), 0));
      }
      expect(trail.length, 3);
      expect(trail.points.map((p) => p.x), [2, 3, 4]);
    });

    test('fades from the tail, so the streak is drawn into the craft', () {
      final trail = Trail(capacity: 4);
      for (var i = 0; i < 3; i++) {
        trail.add(Vec(i.toDouble(), 0));
      }
      trail.fade();
      expect(trail.points.map((p) => p.x), [1, 2]);
    });

    test('can be faded away to nothing without complaining', () {
      final trail = Trail(capacity: 4)..add(const Vec(0, 0));
      trail.fade();
      trail.fade();
      expect(trail.isEmpty, isTrue);
    });

    test('says it has changed only when it has', () {
      final trail = Trail(capacity: 4);
      final start = trail.revision;
      trail.clear();
      expect(trail.revision, start, reason: 'clearing nothing changes nothing');
      trail.add(const Vec(1, 1));
      expect(trail.revision, greaterThan(start));
      final added = trail.revision;
      trail.fade();
      expect(trail.revision, greaterThan(added));
      final faded = trail.revision;
      trail.fade();
      expect(trail.revision, faded, reason: 'there was nothing left to fade');
    });
  });
}
