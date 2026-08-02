import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../game/board.dart';
import 'board_view.dart';
import 'palette.dart';
import 'tracer.dart';
import 'word_banner.dart';

/// The board and the line that talks about it.
///
/// This is the part of the game a thumb touches: it holds the board, hands
/// finished traces to it, and says what came of each one. The score, the
/// clock and the list of words found are built outside it and passed in, so
/// nothing about keeping score is decided here, but the board is what gets
/// whatever room they leave.
class PlayArea extends StatefulWidget {
  const PlayArea({
    super.key,
    required this.board,
    this.onBoard,
    this.above,
    this.middle,
  });

  final Board board;

  /// The board after a word was taken, for whatever is keeping score.
  final ValueChanged<Board>? onBoard;

  /// The score and the clock, across the top. It takes the height it asks
  /// for.
  final Widget? above;

  /// Whatever is worth putting in the room a square board leaves on a
  /// phone-shaped screen: the words found so far. It gets what is left after
  /// the board has taken its square.
  final Widget? middle;

  @override
  State<PlayArea> createState() => _PlayAreaState();
}

class _PlayAreaState extends State<PlayArea> {
  /// How long an answer stays up before the board goes quiet again. Long
  /// enough to read after looking down at the thumb, short enough that it is
  /// gone by the time the next word is traced.
  static const _linger = Duration(milliseconds: 1600);

  /// Room around the board, so the outer squares are not against the edge of
  /// the screen where a palm rests.
  static const _room = 12.0;

  late Board _board = widget.board;

  final ValueNotifier<Wording> _banner = ValueNotifier(const Wording());

  /// The word under the thumb, which wins the line whenever there is one.
  Wording? _live;

  /// What the last trace came to, until it times out.
  Wording? _said;
  Timer? _quieten;

  @override
  void didUpdateWidget(PlayArea old) {
    super.didUpdateWidget(old);
    if (!identical(old.board, widget.board)) _board = widget.board;
  }

  @override
  void dispose() {
    _quieten?.cancel();
    _banner.dispose();
    super.dispose();
  }

  void _refresh() => _banner.value = _live ?? _said ?? const Wording();

  void _traced(Trace trace) {
    // A trace on its way out has already had its say.
    if (trace.settling) return;
    if (trace.isEmpty) {
      _live = null;
    } else {
      _live = Wording(
        word: trace.word,
        // Nothing is said about a trace that is not a word yet, because most
        // of the way through most words it is not one.
        note: switch (trace.verdict) {
          Refusal.none => '+${Board.scoreOf(trace.word)}',
          Refusal.alreadyFound => 'already found',
          _ => '',
        },
        tone: switch (trace.verdict) {
          Refusal.none => Palette.word,
          Refusal.alreadyFound => Palette.stale,
          _ => Palette.trace,
        },
      );
      _said = null;
      _quieten?.cancel();
    }
    _refresh();
  }

  void _lifted(List<Spot> spots, Refusal verdict) {
    _live = null;
    _quieten?.cancel();

    if (spots.isEmpty) {
      _said = null;
      _refresh();
      return;
    }

    final word = _board.wordFor(spots);
    _said = switch (verdict) {
      Refusal.none => Wording(
          word: word,
          note: '+${Board.scoreOf(word)}',
          tone: Palette.word,
        ),
      Refusal.alreadyFound =>
        Wording(word: word, note: 'already found', tone: Palette.stale),
      Refusal.tooShort =>
        Wording(word: word, note: 'too short', tone: Palette.inkDim),
      // Broken and repeated cannot arrive here: the tracer will not build a
      // trace that has either fault in it. What is left is a word the game
      // does not know.
      _ => Wording(word: word, note: 'not a word', tone: Palette.inkDim),
    };
    _quieten = Timer(_linger, () {
      _said = null;
      _refresh();
    });
    _refresh();

    if (verdict == Refusal.none) {
      setState(() => _board = _board.take(spots));
      widget.onBoard?.call(_board);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Palette.backdrop,
      // The face comes from whatever is hosting this, but the colour and the
      // absence of decoration do not: a screen with no Material above it hands
      // down a debug style that would draw a yellow rule under every letter on
      // the board.
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          color: Palette.ink,
          decoration: TextDecoration.none,
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (widget.above != null) widget.above!,
              Expanded(
                child: LayoutBuilder(
                  builder: (context, space) {
                    // A phone screen is a good deal taller than a square board
                    // is wide, and the slack has to go somewhere. It goes
                    // above the board, where the words found can use it,
                    // rather than between the board and the line about it.
                    //
                    // The board keeps at most seven tenths of the height so
                    // there is always somewhere for those words to be, and it
                    // sits at the bottom where the thumb is.
                    final side = math.max(
                      0.0,
                      math.min(
                        space.maxWidth - _room * 2,
                        space.maxHeight * 0.7,
                      ),
                    );
                    return Column(
                      children: [
                        // Flexible rather than Expanded: the board takes its
                        // square first and this takes what is left, instead
                        // of the two of them splitting the room between
                        // them.
                        Flexible(
                          child: widget.middle ?? const SizedBox.expand(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                          child: ValueListenableBuilder<Wording>(
                            valueListenable: _banner,
                            builder: (context, wording, _) =>
                                WordBanner(wording: wording),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(_room),
                          // Square, so the grid is as big as the narrower
                          // side allows and none of the drag lands on screen
                          // that is not board.
                          child: SizedBox.square(
                            dimension: side,
                            child: BoardView(
                              board: _board,
                              onTrace: _traced,
                              onLift: _lifted,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
