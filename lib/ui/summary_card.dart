import 'package:flutter/material.dart';

import '../best_score.dart';
import '../game/round.dart';
import 'chrome.dart';
import 'palette.dart';

/// The end of a round: what was found, what was there, and a way straight
/// back in.
///
/// The missed words are the reason to look at this screen. The board knows
/// every word it holds, and a player who spent two minutes on it wants to
/// know what was under their thumb the whole time, longest first, because
/// that is the one that got away.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.round,
    required this.best,
    required this.ranOut,
    required this.beatBest,
    required this.reveal,
    required this.onAgain,
    required this.onSameAgain,
    required this.onTitle,
  });

  final Round round;
  final BestScore best;

  /// Whether the clock ended the round rather than the player.
  final bool ranOut;

  /// Whether this round took the record. Worked out before it was saved,
  /// since saving it is what stops it being true.
  final bool beatBest;

  /// Nought as the round ends, one once the card has arrived.
  final Animation<double> reveal;

  /// A new board.
  final VoidCallback onAgain;

  /// This board again, which is the whole point of a round being a number.
  final VoidCallback onSameAgain;

  final VoidCallback onTitle;

  /// How many of the missed words are worth listing.
  ///
  /// A five by five board holds well over a hundred, and a list that long is
  /// not read, it is scrolled past. These are the longest ones, which are the
  /// ones worth regretting.
  static const _worthShowing = 24;

  @override
  Widget build(BuildContext context) {
    final missed = round.missed;
    final cleared = missed.isEmpty;

    return AnimatedBuilder(
      animation: reveal,
      builder: (context, child) => IgnorePointer(
        // Nothing here can be hit until the card has finished arriving. The
        // player had a thumb on the board a moment ago, and that thumb must
        // not spend itself on a button that appeared under it.
        ignoring: reveal.value < 1,
        child: Opacity(
          opacity: reveal.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - reveal.value)),
            child: child,
          ),
        ),
      ),
      child: ColoredBox(
        color: Palette.scrim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The headline and the figures are display-sized already, so
                // they follow the system's text setting part of the way
                // rather than all of it. What is under them is prose and
                // scales the whole way.
                MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cleared
                            ? 'Board cleared'
                            : ranOut
                                ? 'Time'
                                : 'Round over',
                        style: TextStyle(
                          color: cleared ? Palette.word : Palette.ink,
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Side by side while they fit and stacked when they do
                      // not, which is what a narrow screen at a large text
                      // setting gives these.
                      Wrap(
                        spacing: 36,
                        runSpacing: 18,
                        // Sat on the same line as each other, so the two
                        // labels read as one row rather than a staircase.
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Readout(
                            value: '${round.score}',
                            label: 'points',
                            tone: Palette.word,
                            size: 56,
                          ),
                          Readout(
                            value: '${round.found.length} of '
                                '${round.words.length}',
                            label: 'words found',
                            tone: Palette.ink,
                            size: 34,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // What the board was worth, which is what makes the
                      // score above mean anything.
                      Text(
                        'there were ${round.possible} points on this board',
                        style: labelStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (beatBest)
                  const Text(
                    'New best',
                    style: TextStyle(
                      color: Palette.stale,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  )
                else
                  Text(bestLine(best.points, best.seed), style: labelStyle),
                const SizedBox(height: 6),
                Text('seed ${round.seed}', style: labelStyle),
                const SizedBox(height: 26),
                // Above the word lists rather than under them. The lists are
                // long by design, and the player who wants another go should
                // not have to scroll past a hundred words they did not find
                // to start one.
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: onAgain,
                      child: const Text('New board'),
                    ),
                    TextButton(
                      onPressed: onSameAgain,
                      child: const Text('This board again'),
                    ),
                    TextButton(onPressed: onTitle, child: const Text('Title')),
                  ],
                ),
                const SizedBox(height: 26),
                _Section(
                  title: 'Found',
                  words: Round.ranked(round.found),
                  tone: Palette.word,
                  empty: 'nothing this time',
                ),
                if (!cleared) ...[
                  const SizedBox(height: 22),
                  _Section(
                    title: 'Missed',
                    words: missed.take(_worthShowing).toList(),
                    tone: Palette.inkDim,
                    empty: '',
                    more: missed.length - _worthShowing,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A heading and a bag of words under it.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.words,
    required this.tone,
    required this.empty,
    this.more = 0,
  });

  final String title;
  final List<String> words;
  final Color tone;

  /// What to say instead when there are none.
  final String empty;

  /// How many were left off the end of the list.
  final int more;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          words.isEmpty
              ? title
              : '$title  ${words.length + (more > 0 ? more : 0)}',
          style: labelStyle.copyWith(color: tone),
        ),
        const SizedBox(height: 12),
        if (words.isEmpty)
          Text(empty, style: noteStyle)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final word in words) WordChip(word: word, tone: tone),
              if (more > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Text('and $more more', style: labelStyle),
                ),
            ],
          ),
      ],
    );
  }
}
