import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haulyard/ui/title_screen.dart';
import 'package:haulyard/ui/yard_screen.dart';
import 'package:haulyard/yard/haul.dart';
import 'package:haulyard/yard/levels.dart';
import 'package:haulyard/yard/yard.dart';

import '../support/yard.dart';

void main() {
  group('getting in', () {
    testWidgets('opens on the yards', (tester) async {
      await open(tester);
      expect(find.byType(TitleScreen), findsOne);
      expect(find.text('The first one'), findsOne);
      expect(find.text('Last out'), findsOne);
    });

    testWidgets('a yard opens when its row is tapped', (tester) async {
      await open(tester);
      await tester.ensureVisible(find.text('The pinch'));
      await tester.pump();
      await tester.tap(find.text('The pinch'));
      await tester.pump();

      expect(find.byType(YardScreen), findsOne);
      expect(state(tester).level.name, 'The pinch');
    });

    testWidgets('and going back leaves it', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      expect(find.byType(TitleScreen), findsOne);
    });
  });

  group('working a yard', () {
    testWidgets('a swipe takes a step', (tester) async {
      await open(tester, which: 0);
      final was = state(tester).yard.hauler;

      await swipe(tester, Way.left);
      expect(state(tester).yard.hauler, isNot(was));
      expect(state(tester).yard.pushes, 0, reason: 'walking is not a shove');
    });

    testWidgets('a swipe into a crate shoves it, and it counts',
        (tester) async {
      // The first yard is a crate with the mark above it and the hauler
      // below, so a swipe upwards shoves it towards home.
      await open(tester, which: 0);
      final crate = state(tester).yard.crates.single;

      await swipe(tester, Way.up);
      expect(state(tester).yard.crates.single, isNot(crate));
      expect(state(tester).yard.pushes, 1);
    });

    testWidgets('a tap walks across the yard for nothing', (tester) async {
      await open(tester, which: 0);
      final yard = state(tester).yard;
      final far = yard.reach.reduce((a, b) => a > b ? a : b);

      await tapSquare(tester, far);
      expect(state(tester).yard.hauler, far);
      expect(state(tester).yard.pushes, 0,
          reason: 'walking cannot make a yard worse, so it is not counted');
    });

    testWidgets('a tap on a crate beside the hauler shoves it', (tester) async {
      await open(tester, which: 0);
      final crate = state(tester).yard.crates.single;

      await tapSquare(tester, crate);
      expect(state(tester).yard.pushes, 1);
    });

    testWidgets('and a tap on a crate anywhere else does nothing',
        (tester) async {
      await open(tester, which: 4);
      final far = state(tester).yard.crates.last;
      final was = state(tester).yard.hauler;

      await tapSquare(tester, far);
      expect(state(tester).yard.hauler, was);
      expect(state(tester).yard.pushes, 0);
    });

    testWidgets('undo takes back a shove, and again puts it all back',
        (tester) async {
      await open(tester, which: 0);
      final start = state(tester).yard.crates.single;

      await swipe(tester, Way.up);
      expect(state(tester).yard.pushes, 1);

      await press(tester, 'Undo');
      expect(state(tester).yard.crates.single, start);
      expect(state(tester).yard.pushes, 0);

      // One shove, not two: two finishes this yard, and a finished yard has
      // no Again on it.
      await swipe(tester, Way.up);
      await press(tester, 'Again');
      expect(state(tester).yard.crates.single, start);
      expect(state(tester).yard.pushes, 0);
    });
  });

  group('a yard that has been spoiled', () {
    testWidgets('says so the moment it happens', (tester) async {
      // The first yard's mark is above the crate. Walked round and shoved the
      // other way instead, the crate ends against the bottom wall — where it
      // can slide sideways for ever and never come off.
      await open(tester, which: 0);
      expect(state(tester).saying, isNull);

      await spoilTheFirstYard(tester);

      expect(state(tester).saying, contains('cannot reach a mark'));
      expect(painterOf(tester).spoiled, isNotNull,
          reason: 'the crate itself should be marked, not just the words');
      expect(haulFrom(tester).canBeDone, isFalse);
    });

    testWidgets('and undoing puts it right', (tester) async {
      await open(tester, which: 0);
      await spoilTheFirstYard(tester);

      await press(tester, 'Undo');
      expect(state(tester).saying, isNull);
      expect(painterOf(tester).spoiled, isNull);
      expect(haulFrom(tester).canBeDone, isTrue);
    });
  });

  group('being shown', () {
    testWidgets('points at a crate and says which way', (tester) async {
      await open(tester, which: 4);
      await press(tester, 'Show me');

      final painter = painterOf(tester);
      expect(painter.pointAt, isNotNull);
      expect(painter.pointWay, isNotNull);
      expect(state(tester).yard.hasCrate(painter.pointAt!), isTrue);
      expect(state(tester).saying, contains('Shove that one'));
    });

    testWidgets('and what it points at is on a shortest way through',
        (tester) async {
      // Not just any shove that works: the first shove of a way through that
      // nothing beats.
      for (final which in [1, 4, 7]) {
        await open(tester, which: which);
        await press(tester, 'Show me');

        final painter = painterOf(tester);
        final shove = Shove(painter.pointAt!, painter.pointWay!);
        final after = state(tester).yard.after(shove)!;

        expect(haulFrom(tester).pushes, Levels.at(which).par);
        expect(
          Hauler(after.ground).from(after).pushes,
          Levels.at(which).par - 1,
          reason: 'that shove did not get any closer to the end',
        );
      }
    });

    testWidgets('says so when the yard cannot be finished at all',
        (tester) async {
      await open(tester, which: 0);
      await spoilTheFirstYard(tester);

      await press(tester, 'Show me');
      expect(state(tester).saying, contains('cannot be finished'));
      expect(painterOf(tester).pointAt, isNull);
    });

    testWidgets('works every yard through, in par, from the first shove to '
        'the last', (tester) async {
      // The claim the game is sold on, made through the screen: the par on
      // each yard is reachable, and following what the game says reaches it.
      for (var which = 0; which < Levels.count; which++) {
        await open(tester, which: which);
        await workItThrough(tester);

        expect(state(tester).yard.isDone, isTrue,
            reason: '${Levels.at(which).name} was not finished');
        expect(state(tester).yard.pushes, Levels.at(which).par,
            reason: '${Levels.at(which).name} took more shoves than the par');
        expect(find.text('Nothing wasted'), findsOne);
      }
    });
  });

  group('finishing', () {
    testWidgets('a yard done the long way says how much longer', (tester) async {
      await open(tester, which: 0);
      // Down, and back up, and down again: two shoves wasted.
      await swipe(tester, Way.down);
      await swipe(tester, Way.left);
      await tapSquare(tester, state(tester).yard.crates.single + 1);
      await tapSquare(tester, state(tester).yard.crates.single);
      await workItThrough(tester);

      expect(state(tester).yard.isDone, isTrue);
      expect(state(tester).yard.pushes, greaterThan(Levels.at(0).par));
      expect(find.text('Yard cleared'), findsOne);
      expect(find.textContaining('more than it had to be'), findsOne);
    });

    testWidgets('and the next one opens after it', (tester) async {
      await open(tester, which: 0);
      await workItThrough(tester);

      await press(tester, 'The next one');
      expect(state(tester).level.name, Levels.at(1).name);
      expect(state(tester).yard.pushes, 0);
    });

    testWidgets('the last one leads back to the list', (tester) async {
      await open(tester, which: Levels.count - 1);
      await workItThrough(tester);

      await press(tester, 'The next one');
      expect(find.byType(TitleScreen), findsOne);
    });
  });

  group('the yard on the screen', () {
    testWidgets('keeps its squares square on every phone', (tester) async {
      const phones = [Size(960, 1704), Size(1170, 2532), Size(1440, 3120)];
      for (final screen in phones) {
        await open(tester, which: 11, screen: screen);
        final metrics = metricsOf(tester);
        expect(metrics.board.width / metrics.across,
            closeTo(metrics.board.height / metrics.down, 0.001));
      }
    });

    testWidgets('finds the square under a finger', (tester) async {
      await open(tester, which: 4);
      final metrics = metricsOf(tester);
      for (final at in [0, 9, metrics.across * metrics.down - 1]) {
        expect(metrics.under(metrics.squareAt(at).center), at);
      }
      expect(metrics.under(const Offset(-40, -40)), isNull);
    });
  });
}
