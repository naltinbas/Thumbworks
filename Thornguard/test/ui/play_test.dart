import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thornguard/game/board.dart';
import 'package:thornguard/game/game.dart';
import 'package:thornguard/opponent.dart';
import 'package:thornguard/ui/app.dart';
import 'package:thornguard/ui/board_view.dart';
import 'package:thornguard/ui/game_screen.dart';
import 'package:thornguard/ui/result_card.dart';
import 'package:thornguard/ui/title_screen.dart';

import '../support/playing.dart';

/// A phone to lay the game out on.
const phone = Size(1170, 2532);

Future<void> open(
  WidgetTester tester, {
  Side playing = Side.guards,
  Strength strength = Strength.steady,
  bool atBoard = false,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ThornguardApp(
    playing: playing,
    strength: strength,
    opensPlaying: atBoard,
  ));
  await tester.pump();
}

/// Waits for the opponent, which thinks on another thread.
Future<void> letThemThink(WidgetTester tester) async {
  for (var i = 0; i < 200; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 50));
    if (board(tester).turn == Side.guards) return;
  }
}

void main() {
  group('the title', () {
    testWidgets('offers a side and an opponent, and starts a game',
        (tester) async {
      await open(tester);

      expect(find.text('Thornguard'), findsOneWidget);
      expect(find.textContaining('Guards'), findsOneWidget);
      expect(find.textContaining('Raiders'), findsOneWidget);
      expect(find.textContaining('Steady'), findsOneWidget);
      expect(find.byType(BoardView), findsNothing);

      // The title scrolls: three ways to describe an opponent and two sides
      // do not fit above the fold on a small phone, and the alternative is a
      // settings screen nobody would visit.
      await tester.ensureVisible(find.text('Play'));
      await tester.pump();
      await tester.tap(find.text('Play'));
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(BoardView), findsOneWidget);
    });

    testWidgets('picking the other side changes what is chosen',
        (tester) async {
      await open(tester);

      await tester.tap(find.textContaining('Raiders'));
      await tester.pump();

      final title = tester.widget<TitleScreen>(find.byType(TitleScreen));
      expect(title.playing, Side.raiders);
    });
  });

  group('picking a man up', () {
    testWidgets('shows where he can go', (tester) async {
      // The player has the raiders, so it is their move from the off.
      await open(tester, playing: Side.raiders, atBoard: true);

      await tapSquare(tester, const Square(0, 2));
      expect(boardView(tester).picked, const Square(0, 2));
      expect(boardView(tester).destinations, hasLength(3),
          reason: 'two squares inward and one along the edge');
    });

    testWidgets('putting him back down clears it', (tester) async {
      await open(tester, playing: Side.raiders, atBoard: true);

      await tapSquare(tester, const Square(0, 2));
      await tapSquare(tester, const Square(0, 2));
      expect(boardView(tester).picked, isNull);
    });

    testWidgets('tapping another of your own picks that one up instead',
        (tester) async {
      await open(tester, playing: Side.raiders, atBoard: true);

      await tapSquare(tester, const Square(0, 2));
      await tapSquare(tester, const Square(0, 4));
      expect(boardView(tester).picked, const Square(0, 4));
    });

    testWidgets('the other side cannot be picked up at all', (tester) async {
      await open(tester, playing: Side.raiders, atBoard: true);

      await tapSquare(tester, const Square(3, 2));
      expect(boardView(tester).picked, isNull, reason: 'that is a guard');
    });
  });

  group('moving', () {
    testWidgets('puts the man down and hands over the turn', (tester) async {
      await open(tester, playing: Side.raiders, atBoard: true);

      await tapSquare(tester, const Square(0, 2));
      await tapSquare(tester, const Square(2, 2));

      expect(board(tester).at(const Square(2, 2)), Piece.raider);
      expect(board(tester).at(const Square(0, 2)), isNull);
      expect(boardView(tester).picked, isNull);
    });

    testWidgets('a tap on a square he cannot reach does nothing but put him '
        'down', (tester) async {
      await open(tester, playing: Side.raiders, atBoard: true);

      await tapSquare(tester, const Square(0, 2));
      // Diagonally, which nothing in this game may do.
      await tapSquare(tester, const Square(1, 1));

      expect(board(tester).at(const Square(0, 2)), Piece.raider);
      expect(boardView(tester).picked, isNull);
      expect(board(tester).turn, Side.raiders, reason: 'still their move');
    });

    testWidgets('the board does not answer while it is not your move',
        (tester) async {
      // The player has the guards, so the raiders move first and the board is
      // frozen until they have.
      await open(tester, atBoard: true);
      expect(boardView(tester).frozen, isTrue);

      await tapSquare(tester, const Square(3, 2));
      expect(boardView(tester).picked, isNull);
    });
  });

  group('the opponent', () {
    testWidgets('moves, on its own thread, and the board says so',
        (tester) async {
      await open(tester, atBoard: true);
      expect(board(tester).turn, Side.raiders);

      await letThemThink(tester);

      expect(board(tester).turn, Side.guards, reason: 'they did not move');
      expect(boardView(tester).last, isNotNull);
      expect(boardView(tester).frozen, isFalse);
    });
  });

  group('taking it back', () {
    testWidgets('undoes both moves, so the position is the one you saw',
        (tester) async {
      await open(tester, playing: Side.raiders, atBoard: true);

      await tapSquare(tester, const Square(0, 2));
      await tapSquare(tester, const Square(2, 2));
      await letThemThink(tester);
      // Their reply lands, and it is our move again.
      await tester.pump();

      await tester.tap(find.text('Take it back'));
      await tester.pump();

      expect(board(tester), Board.opening());
      expect(board(tester).turn, Side.raiders);
    });

    testWidgets('is dead before anything has been played', (tester) async {
      await open(tester, playing: Side.raiders, atBoard: true);
      await tester.tap(find.text('Take it back'));
      await tester.pump();
      expect(board(tester), Board.opening());
    });
  });

  group('the end', () {
    testWidgets('says who won and offers another game', (tester) async {
      // A position one move from the king reaching a corner, with the player
      // on the guards.
      final nearlyOut = Game.at(Board.of(const [
        '   K   ',
        '       ',
        '       ',
        '       ',
        '       ',
        '       ',
        '   R   ',
      ], turn: Side.guards));

      await tester.pumpWidget(MaterialApp(
        theme: ThornguardApp.theme,
        home: GameScreen(
          playing: Side.guards,
          strength: Strength.steady,
          onLeave: () {},
          opening: nearlyOut,
        ),
      ));
      await tester.pump();

      await tapSquare(tester, const Square(0, 3));
      await tapSquare(tester, const Square(0, 0));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ResultCard), findsOneWidget);
      expect(find.text('The king is away'), findsOneWidget);
      expect(find.text('You win.'), findsOneWidget);
      expect(find.text('Play again'), findsOneWidget);
    });
  });

  group('fitting a phone', () {
    for (final entry in const {
      'iphone-se': Size(320, 568),
      'iphone-14': Size(390, 844),
      'pixel-7': Size(412, 915),
    }.entries) {
      testWidgets('the board fits and is playable on ${entry.key}',
          (tester) async {
        await open(
          tester,
          playing: Side.raiders,
          atBoard: true,
          screen: entry.value * 3,
        );

        final view = tester.getRect(find.byType(BoardView));
        final metrics = metricsOf(tester);

        expect(metrics.board.width, lessThanOrEqualTo(view.width + 0.5));
        expect(metrics.board.height, lessThanOrEqualTo(view.height + 0.5));
        expect(metrics.square, greaterThan(38),
            reason: 'a square a thumb can hit');

        await tapSquare(tester, const Square(0, 2));
        await tapSquare(tester, const Square(2, 2));
        expect(board(tester).at(const Square(2, 2)), Piece.raider);
      });
    }
  });
}
