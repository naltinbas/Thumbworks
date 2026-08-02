import 'package:flutter/material.dart' hide Table;

import '../game/book.dart';
import '../game/table.dart';
import 'palette.dart';
import 'table_painter.dart';

/// The way in.
///
/// One decision, which is Play, and one thing worth saying: every deal in here
/// has been won already, by the solver in this app, before anybody was offered
/// it. That is the whole promise and it belongs on the first screen.
class TitleScreen extends StatelessWidget {
  const TitleScreen({
    super.key,
    required this.place,
    required this.onPlay,
    required this.onPick,
  });

  /// Where in the book the player is up to.
  final int place;

  final VoidCallback onPlay;

  /// Play a different deal, by its number.
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final number = Book.at(place);
    return Scaffold(
      backgroundColor: Palette.felt,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            children: [
              // The mark: a few cards from the deal about to be played, drawn
              // by the painter that draws the game.
              SizedBox(
                width: 220,
                height: 130,
                child: CustomPaint(
                  painter: TablePainter(
                    table: _fan,
                    metrics: Metrics(const Size(220, 380)),
                    text: Theme.of(context).textTheme.bodyMedium!,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Fanwright',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 38,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Eight columns, four cells, four piles.\n'
                'Tap a card and it goes where it should.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.inkDim,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Palette.feltDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Palette.slotEdge, width: 1.1),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Every deal in here can be won',
                      style: TextStyle(
                        color: Palette.good,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${Book.count} of them, each one already solved by the '
                      'same solver the hint button uses.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Palette.inkDim,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: onPlay,
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.good,
                    foregroundColor: Palette.feltDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Deal $number',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                place == 0
                    ? 'the first one'
                    : 'number ${place + 1} in the book',
                style: const TextStyle(color: Palette.inkDim, fontSize: 13),
              ),
              const SizedBox(height: 14),
              _Pick(place: place, onPick: onPick),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// A few cards, for the mark. Not a deal — just a hand worth looking at.
  static final _fan = Table.of(columns: const [
    'KS QH JS',
    'AD',
    '',
    '',
    '',
    '',
    '',
    '',
  ]);
}

/// Back a deal and on a deal, for a player who wants a different one.
class _Pick extends StatelessWidget {
  const _Pick({required this.place, required this.onPick});

  final int place;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Step(
            icon: Icons.chevron_left_rounded,
            label: 'The deal before',
            onTap: place > 0 ? () => onPick(place - 1) : null,
          ),
          const SizedBox(width: 26),
          _Step(
            icon: Icons.chevron_right_rounded,
            label: 'The deal after',
            onTap: () => onPick(place + 1),
          ),
        ],
      );
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Palette.slotEdge, width: 1.1),
            ),
            child: Icon(
              icon,
              color: onTap == null ? Palette.slotEdge : Palette.inkDim,
            ),
          ),
        ),
      );
}
