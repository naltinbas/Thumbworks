import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'chrome.dart';
import 'palette.dart';

/// The words found so far, between the score and the board.
///
/// It fills the room a square board leaves on a phone-shaped screen, and it
/// fills more of it the longer the round goes, so the screen builds up as the
/// player does. A word already used is worth knowing about: without this the
/// only way to find out is to trace it again and be told.
class FoundList extends StatelessWidget {
  const FoundList({super.key, required this.words});

  /// Oldest first, the order the board keeps them in.
  final List<String> words;

  @override
  Widget build(BuildContext context) {
    // Clamped for the same reason the score is: this sits above the board,
    // and a bag of chips at three times the size would take the board's room.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: LayoutBuilder(
        builder: (context, space) => SingleChildScrollView(
          // Anchored at the bottom, so that once there are more words than
          // fit, the ones on screen are the newest. While they still fit they
          // sit in the middle of the room they have, rather than leaving all
          // of it in one lump under the score.
          reverse: true,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: ConstrainedBox(
            // The padding above and below comes off, so that filling the room
            // is not one pixel more than the room.
            constraints: BoxConstraints(
              minHeight: math.max(0, space.maxHeight - 16),
            ),
            child: Center(
              child: words.isEmpty
                  ? const Text('words you find land here', style: labelStyle)
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (var i = 0; i < words.length; i++)
                          WordChip(
                            word: words[i],
                            // The newest is lit, so a word that has just
                            // landed is findable in a bag of thirty.
                            tone: i == words.length - 1
                                ? Palette.word
                                : Palette.inkDim,
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
