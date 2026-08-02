import 'package:flutter/widgets.dart';

import 'palette.dart';

/// What the line above the board is saying: the letters, a short note about
/// them, and the colour that answers whether they count.
@immutable
class Wording {
  const Wording({
    this.word = '',
    this.note = 'Trace a word',
    this.tone = Palette.inkDim,
  });

  final String word;
  final String note;
  final Color tone;
}

/// The word being traced, above the board where a thumb is not.
///
/// The letters keep their room whether or not there are any, so the board does
/// not shift up and down as words are traced.
class WordBanner extends StatelessWidget {
  const WordBanner({super.key, required this.wording});

  final Wording wording;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 52,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                wording.word.toUpperCase(),
                maxLines: 1,
                style: TextStyle(
                  color: wording.tone,
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 6,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            wording.note,
            maxLines: 1,
            style: TextStyle(
              color: wording.tone,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
