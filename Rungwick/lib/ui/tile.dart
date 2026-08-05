import 'package:flutter/material.dart';

import 'palette.dart';

/// One letter of one word.
class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.letter,
    this.side = 52,
    this.changed = false,
    this.lit = false,
    this.faded = false,
    this.wrong = false,
  });

  final String letter;
  final double side;

  /// Whether this is the letter that changed to make this rung. The one thing
  /// worth marking on a word: which letter moved.
  final bool changed;

  /// Whether this is the letter being changed right now.
  final bool lit;

  /// Whether this is a rung already climbed rather than the one in hand.
  final bool faded;

  /// Whether the word this is part of was just turned down.
  final bool wrong;

  @override
  Widget build(BuildContext context) {
    final edge = wrong
        ? Palette.bad
        : lit
            ? Palette.rope
            : changed
                ? Palette.rope.withValues(alpha: 0.55)
                : Palette.rungEdge;

    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: lit ? Palette.rope.withValues(alpha: 0.16) : Palette.rung,
        borderRadius: BorderRadius.circular(side * 0.18),
        border: Border.all(color: edge, width: lit ? 2 : 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          color: faded ? Palette.inkDim : Palette.ink,
          fontSize: side * 0.46,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// A whole word, as tiles.
class Word extends StatelessWidget {
  const Word({
    super.key,
    required this.word,
    this.side = 52,
    this.changedAt = -1,
    this.litAt = -1,
    this.faded = false,
    this.wrong = false,
    this.onTapLetter,
  });

  final String word;
  final double side;

  /// Which letter changed to make this word, if it is a rung.
  final int changedAt;

  /// Which letter is being changed, if this is the word in hand.
  final int litAt;

  final bool faded;
  final bool wrong;
  final ValueChanged<int>? onTapLetter;

  @override
  Widget build(BuildContext context) {
    final tiles = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var at = 0; at < word.length; at++) ...[
          if (at > 0) SizedBox(width: side * 0.12),
          _one(at),
        ],
      ],
    );

    // A word nobody can touch is one thing to hear about rather than four.
    return onTapLetter == null
        ? Semantics(label: word, child: ExcludeSemantics(child: tiles))
        : tiles;
  }

  Widget _one(int at) {
    final tile = Tile(
      letter: word[at],
      side: side,
      changed: at == changedAt,
      lit: at == litAt,
      faded: faded,
      wrong: wrong,
    );
    if (onTapLetter == null) return tile;

    // The letter drawn on the tile is left out of what is announced, because
    // the label below already says it — and a node that carries both comes
    // out as neither.
    return Semantics(
      button: true,
      label: 'change the ${_ordinal(at)} letter, ${word[at]}',
      child: GestureDetector(
        onTap: () => onTapLetter!(at),
        child: ExcludeSemantics(child: tile),
      ),
    );
  }

  static String _ordinal(int at) => switch (at) {
        0 => 'first',
        1 => 'second',
        2 => 'third',
        3 => 'fourth',
        4 => 'fifth',
        _ => '${at + 1}th',
      };
}
