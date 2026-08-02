import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chalkway/sim/levels.dart';
import 'package:chalkway/sim/shapes.dart';
import 'package:chalkway/sim/world.dart';
import 'package:chalkway/ui/board_screen.dart';
import 'package:chalkway/ui/result_card.dart';
import 'package:chalkway/ui/title_screen.dart';

import '../support/board.dart';

void main() {
  group('getting in', () {
    testWidgets('opens on the list of levels', (tester) async {
      await open(tester);
      expect(find.byType(TitleScreen), findsOne);
      expect(find.text('A slope'), findsOne);
      expect(find.text('The hole'), findsOne);
    });

    testWidgets('a level opens when its row is tapped', (tester) async {
      await open(tester);
      await tester.tap(find.text('The gap'));
      await tester.pump();

      expect(find.byType(BoardScreen), findsOne);
      expect(state(tester).level.name, 'The gap');
    });

    testWidgets('and going back leaves it', (tester) async {
      await open(tester, level: 1);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      expect(find.byType(TitleScreen), findsOne);
    });
  });

  group('drawing', () {
    testWidgets('a finger across the board leaves chalk', (tester) async {
      await open(tester, level: 0);
      expect(state(tester).drawing.used, 0);

      await drawFrom(tester, const Spot(2, 8), const Spot(6, 10));

      final drawing = state(tester).drawing;
      expect(drawing.strokes, hasLength(1));
      expect(drawing.used, closeTo(4.47, 0.3),
          reason: 'the stroke is as long as the line the finger made');
    });

    testWidgets('and the ball rolls down it', (tester) async {
      await open(tester, level: 0);
      await drawFrom(tester, const Spot(1.4, 4), const Spot(6, 6));

      await press(tester, 'Let go');
      await runOut(tester);

      // Wherever it ended up, it is not below where it started by the shortest
      // way — it went along the chalk first.
      expect(state(tester).world!.ball.x, greaterThan(3));
    });

    testWidgets('rubbing out takes back the last stroke only',
        (tester) async {
      await open(tester, level: 0);
      await drawFrom(tester, const Spot(2, 7), const Spot(5, 8));
      await drawFrom(tester, const Spot(2, 12), const Spot(5, 13));
      expect(state(tester).drawing.strokes, hasLength(2));

      await press(tester, 'Rub out');
      expect(state(tester).drawing.strokes, hasLength(1));
      expect(state(tester).drawing.strokes.single.points.first.y,
          closeTo(7, 0.2));
    });

    testWidgets('runs out of chalk, and the line stops where it ran out',
        (tester) async {
      await open(tester, level: 1);
      final ink = state(tester).level.ink;

      // Right across the board, which is more than any level gives.
      await drawFrom(tester, const Spot(0.4, 6), const Spot(9.6, 6));

      expect(state(tester).drawing.used, closeTo(ink, 0.05));
      expect(state(tester).drawing.left, closeTo(0, 0.05));
      expect(state(tester).drawing.strokes.single.points.last.x,
          lessThan(9.6),
          reason: 'the stroke was cut, not thrown away');
    });

    testWidgets('nothing can be drawn while the ball is going',
        (tester) async {
      await open(tester, level: 0);
      await drawFrom(tester, const Spot(2, 8), const Spot(5, 9));
      final was = state(tester).drawing.used;

      await press(tester, 'Let go');
      await tester.pump(const Duration(milliseconds: 100));
      await drawFrom(tester, const Spot(2, 14), const Spot(6, 15));

      expect(state(tester).drawing.used, was);
    });
  });

  group('a run', () {
    testWidgets("is won by the level's own answer, drawn by hand",
        (tester) async {
      // The claim the game is sold on, made the way a player makes it: the
      // shipped line, drawn with a finger, on the real screen.
      await open(tester, level: 0);
      await drawTheAnswer(tester);

      expect(await letGo(tester), Ending.home);
      expect(find.byType(ResultCard), findsOne);
      expect(find.text('In'), findsOne);
    });

    testWidgets('is lost with nothing drawn, and says so', (tester) async {
      await open(tester, level: 2);
      expect(await letGo(tester), isNot(Ending.home));
      expect(find.text('In'), findsNothing);
      expect(find.text('Try again'), findsOne);
    });

    testWidgets('starts over on Try again, with the drawing still there',
        (tester) async {
      await open(tester, level: 2);
      await drawFrom(tester, const Spot(6, 9), const Spot(8, 10));
      final was = state(tester).drawing.used;

      await letGo(tester);
      await press(tester, 'Try again');

      expect(state(tester).world, isNull, reason: 'the ball is back at the top');
      expect(state(tester).drawing.used, was,
          reason: 'a failed run should not cost you the line you drew');
      expect(find.byType(ResultCard), findsNothing);
    });

    testWidgets('leaves a trail behind the ball', (tester) async {
      await open(tester, level: 0);
      await press(tester, 'Let go');
      // A handful of frames, not one long one: the first tick of a ticker only
      // says what time it is, and a frame may catch up on eighty milliseconds
      // of world at most however long it was away.
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(painterOf(tester).trail.length, greaterThan(2));
    });

    testWidgets('goes to the next level after a win', (tester) async {
      await open(tester, level: 0, opening: Levels.at(0).answer);
      expect(await letGo(tester), Ending.home);

      await press(tester, 'The next one');
      expect(state(tester).level.name, Levels.at(1).name);
      expect(state(tester).drawing.isEmpty, isTrue,
          reason: 'a new level starts on a clean slate');
    });

    testWidgets('the last level leads back to the list, not off the end',
        (tester) async {
      await open(
        tester,
        level: Levels.count - 1,
        opening: Levels.at(Levels.count - 1).answer,
      );
      expect(await letGo(tester), Ending.home);

      await press(tester, 'The next one');
      expect(find.byType(TitleScreen), findsOne);
    });
  });

  group('the board itself', () {
    testWidgets('is the same shape on every phone', (tester) async {
      // Ten units across and twenty down, whatever it is drawn on. A drawing
      // that solves a level on one phone has to solve it on all of them.
      const phones = [Size(960, 1704), Size(1170, 2532), Size(1440, 3120)];
      for (final screen in phones) {
        await open(tester, level: 0, screen: screen);
        final metrics = metricsOf(tester);
        expect(metrics.board.width / metrics.board.height,
            closeTo(World.across / World.down, 0.001));
      }
    });

    testWidgets('turns a point on the screen back into the same point',
        (tester) async {
      await open(tester, level: 0);
      final metrics = metricsOf(tester);
      const spot = Spot(3.5, 12.25);
      final back = metrics.toWorld(metrics.toScreen(spot));
      expect(back.x, closeTo(spot.x, 0.001));
      expect(back.y, closeTo(spot.y, 0.001));
    });

    testWidgets('shows how much chalk is left, and it goes down',
        (tester) async {
      await open(tester, level: 0);
      final full = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(full.widthFactor, 1);

      await drawFrom(tester, const Spot(2, 8), const Spot(6, 10));
      await tester.pump();

      final after = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(after.widthFactor, lessThan(1));
      expect(after.widthFactor, greaterThan(0));
    });
  });
}
