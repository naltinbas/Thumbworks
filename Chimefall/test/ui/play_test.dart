import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chimefall/play/session.dart';
import 'package:chimefall/tune/tune.dart';
import 'package:chimefall/tune/tunes.dart';
import 'package:chimefall/ui/play_screen.dart';
import 'package:chimefall/ui/result_card.dart';
import 'package:chimefall/ui/title_screen.dart';

import '../support/playing.dart';

void main() {
  group('the list of tunes', () {
    testWidgets('says what each one is, and starts it', (tester) async {
      await open(tester, playing: false);

      expect(find.text('Chimefall'), findsOneWidget);
      expect(find.text('The music and the notes are one list'), findsOneWidget);
      for (final tune in Tunes.all) {
        expect(find.text(tune.name), findsOneWidget);
      }
      expect(find.byType(PlayScreen), findsNothing);

      await tester.ensureVisible(find.text(Tunes.first.name));
      await tester.tap(find.text(Tunes.first.name));
      await tester.pump();

      expect(find.byType(PlayScreen), findsOneWidget);
      expect(find.byType(TitleScreen), findsNothing);
    });

    testWidgets('calls the busiest one relentless', (tester) async {
      await open(tester, playing: false);
      expect(find.textContaining('gentle'), findsOneWidget);
      expect(find.textContaining('relentless'), findsOneWidget);
    });
  });

  group('playing', () {
    testWidgets('notes fall towards the line as the tune goes on',
        (tester) async {
      await open(tester, tune: Tunes.first);

      // The first note is at the very start, so a later one is what falls.
      final note = Tunes.first.inOrder[3];
      final due = note.secondsAt(Tunes.first.beatsPerMinute);

      await runTo(tester, due - 1.2);
      final high = heightOf(tester, note);
      await runTo(tester, due - 0.4);
      final low = heightOf(tester, note);

      expect(low, greaterThan(high), reason: 'it should be coming down');
      expect(low, lessThan(metricsOf(tester).line),
          reason: 'and not past the line yet');
    });

    testWidgets('a tap on time is perfect and says so', (tester) async {
      await open(tester, tune: Tunes.first);
      final note = Tunes.first.inOrder[2];
      final due = note.secondsAt(Tunes.first.beatsPerMinute);

      await runTo(tester, due);
      await tapLane(tester, note.lane);

      final hits = state(tester).session.hits;
      expect(hits, isNotEmpty);
      expect(hits.last.judgement, Judgement.perfect);
      expect(find.text('Perfect'), findsOneWidget);
    });

    testWidgets('a tap in the wrong lane hits nothing', (tester) async {
      await open(tester, tune: Tunes.first);
      final note = Tunes.first.inOrder[2];
      final due = note.secondsAt(Tunes.first.beatsPerMinute);

      await runTo(tester, due);
      await tapLane(tester, (note.lane + 2) % Tune.lanes);

      expect(state(tester).session.stray, greaterThan(0));
      expect(find.text('Perfect'), findsNothing);
    });

    testWidgets('a note nobody taps is missed, and the screen says so',
        (tester) async {
      await open(tester, tune: Tunes.first);
      final note = Tunes.first.inOrder.first;
      final due = note.secondsAt(Tunes.first.beatsPerMinute);

      await runTo(tester, due + Session.goodWindow + 0.1);

      expect(state(tester).session.countOf(Judgement.missed),
          greaterThanOrEqualTo(1));
      expect(find.text('Missed'), findsOneWidget);
    });

    testWidgets('the run shows once it is worth showing', (tester) async {
      await open(tester, tune: Tunes.first);
      for (var i = 0; i < 4; i++) {
        final note = Tunes.first.inOrder[i];
        await runTo(tester, note.secondsAt(Tunes.first.beatsPerMinute));
        await tapLane(tester, note.lane);
      }
      expect(find.textContaining('in a row'), findsOneWidget);
    });
  });

  group('the end of a tune', () {
    testWidgets('counts everything up and offers another go', (tester) async {
      await open(tester, tune: Tunes.first);
      await runTo(tester, Tunes.first.seconds + 0.1);

      expect(state(tester).session.isOver, isTrue);
      expect(find.byType(ResultCard), findsOneWidget);
      expect(find.text('missed'), findsOneWidget);
      expect(find.text('Again'), findsOneWidget);

      await tester.tap(find.text('Again'));
      await tester.pump();
      expect(find.byType(ResultCard), findsNothing);
      expect(state(tester).session.hits, isEmpty);
    });

    testWidgets('says nothing was dropped when nothing was', (tester) async {
      await open(tester, tune: Tunes.first);
      for (final note in Tunes.first.inOrder) {
        await runTo(tester, note.secondsAt(Tunes.first.beatsPerMinute));
        await tapLane(tester, note.lane);
      }
      await runTo(tester, Tunes.first.seconds + 0.1);

      expect(find.text('Not one dropped'), findsOneWidget);
      expect(state(tester).session.countOf(Judgement.missed), 0);
    });
  });

  group('leaving it', () {
    testWidgets('holds the tune where it was', (tester) async {
      await open(tester, tune: Tunes.first);
      await runTo(tester, 2.0);
      final was = state(tester).session.at;

      for (final phase in const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(phase);
        await tester.pump();
      }
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Held'), findsOneWidget);
      expect(state(tester).session.at, was,
          reason: 'the tune moved on with nobody listening');
    });
  });

  group('fitting a phone', () {
    for (final entry in const {
      'iphone-se': Size(320, 568),
      'iphone-14': Size(390, 844),
      'pixel-7': Size(412, 915),
    }.entries) {
      testWidgets('four lanes fit a thumb on ${entry.key}', (tester) async {
        await open(tester, tune: Tunes.first, screen: entry.value * 3);

        final metrics = metricsOf(tester);
        expect(metrics.lane, greaterThan(60),
            reason: 'a lane a thumb can hit without aiming');
        expect(metrics.line, lessThan(metrics.space.height));
        expect(metrics.line, greaterThan(metrics.space.height * 0.6),
            reason: 'the line sits low, with the reading room above it');

        // And a tap in the far lane still lands in the far lane.
        expect(
          metrics.laneAt(Offset(metrics.space.width - 4, metrics.line)),
          Tune.lanes - 1,
        );
      });
    }
  });
}
