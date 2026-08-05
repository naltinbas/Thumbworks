import 'package:flutter/material.dart';

import 'lamp.dart';
import 'palette.dart';

/// The mark: a lamp lit, and the four it touches out.
///
/// The whole rule in one picture, and it reads at forty eight points — which
/// is the size that decides these things.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onHill = true});

  /// Whether to draw the hillside behind it. Off for the Android adaptive
  /// icon, where the background is a layer of its own.
  final bool onHill;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final side = box.biggest.shortestSide;
          final lamp = side * 0.30;

          return SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [
                if (onHill)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Palette.hill,
                        borderRadius: BorderRadius.circular(side * 0.16),
                      ),
                    ),
                  ),
                // A plus of five lamps: the one pressed and the four it turns.
                for (final where in const [
                  (0.5, 0.5, true),
                  (0.5, 0.19, false),
                  (0.5, 0.81, false),
                  (0.19, 0.5, false),
                  (0.81, 0.5, false),
                ])
                  Positioned(
                    left: side * where.$1 - lamp / 2,
                    top: side * where.$2 - lamp / 2,
                    child: Lamp(lit: where.$3, side: lamp),
                  ),
              ],
            ),
          );
        },
      );
}
