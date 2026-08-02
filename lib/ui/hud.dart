import 'package:flutter/material.dart';

import '../game/play.dart';
import '../game/plots.dart';
import 'palette.dart';

/// The line above the board: which size, how many mines are unaccounted for,
/// and how long it has taken.
class Ledger extends StatelessWidget {
  const Ledger({
    super.key,
    required this.plot,
    required this.play,
    required this.seconds,
    required this.onLeave,
  });

  final Plot plot;
  final Play play;
  final int seconds;
  final VoidCallback onLeave;

  static String clock(int seconds) {
    final minutes = seconds ~/ 60;
    return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
        child: Row(
          children: [
            IconButton(
              onPressed: onLeave,
              icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
              tooltip: 'Back to the plots',
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plot.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Palette.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    plot.about.toLowerCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Palette.inkDim,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _Count(
              icon: Icons.flag_rounded,
              colour: Palette.ember,
              says: '${play.minesLeft}',
            ),
            const SizedBox(width: 14),
            _Count(
              icon: Icons.schedule_rounded,
              colour: Palette.inkDim,
              says: clock(seconds),
            ),
          ],
        ),
      );
}

class _Count extends StatelessWidget {
  const _Count({required this.icon, required this.colour, required this.says});

  final IconData icon;
  final Color colour;
  final String says;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: colour),
          const SizedBox(width: 5),
          Text(
            says,
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      );
}

/// Under the board: what a tap does, and the way to be told why.
class Tools extends StatelessWidget {
  const Tools({
    super.key,
    required this.flagging,
    required this.saying,
    required this.onFlagging,
    required this.onWhy,
  });

  /// Whether a tap plants a flag instead of opening.
  final bool flagging;

  /// The hint on show, if the player asked for one.
  final String? saying;

  final VoidCallback onFlagging;
  final VoidCallback onWhy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (saying != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Palette.plot,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.furrow, width: 1.1),
              ),
              child: Text(
                saying!,
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: _Button(
                  label: flagging ? 'Flagging' : 'Opening',
                  icon: flagging ? Icons.flag_rounded : Icons.crop_square,
                  lit: flagging,
                  onTap: onFlagging,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Button(
                  label: saying == null ? 'Why?' : 'Do it',
                  icon: saying == null
                      ? Icons.help_outline_rounded
                      : Icons.done_rounded,
                  lit: false,
                  onTap: onWhy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.icon,
    required this.lit,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool lit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: lit ? Palette.ember : Palette.plot,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: lit ? Palette.ember : Palette.furrow,
                width: 1.1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: lit ? Palette.night : Palette.ink),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: lit ? Palette.night : Palette.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
