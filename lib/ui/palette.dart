import 'package:flutter/material.dart';

/// The colours, and why they are these ones.
///
/// A nonogram is a pencil puzzle. It was a pencil puzzle for thirty years
/// before it was ever on a screen, and the thing being drawn is a picture in
/// squared paper. So this is paper and ink rather than the dark screen a
/// phone game usually is: warm off-white, near-black squares, a red pencil for
/// the crosses, and grey for a clue that has been dealt with.
///
/// It also makes the one thing that matters obvious. A filled square is the
/// darkest thing on the screen by a distance, so a half finished picture reads
/// as a picture from across the room.
class Palette {
  const Palette._();

  /// The page.
  static const paper = Color(0xFFF4F0E6);

  /// Slightly darker paper, for the strip the clues sit on.
  static const margin = Color(0xFFEBE5D7);

  /// Text, and the darkest thing here.
  static const ink = Color(0xFF23282E);

  /// Text that is not being read right now.
  static const inkDim = Color(0xFF8A8474);

  /// A filled square.
  static const drawn = Color(0xFF2B3440);

  /// The lines of the squared paper.
  static const rule = Color(0xFFD9D2C1);

  /// Every fifth line, so the eye can count in fives instead of ones.
  static const ruleBold = Color(0xFFB4AB95);

  /// A square marked as not part of the picture. Red pencil, because that is
  /// what it is on paper, and because it must not be mistaken for a filled
  /// square at a glance.
  static const crossed = Color(0xFFB85742);

  /// A clue whose line is finished.
  static const spent = Color(0xFFBEB7A5);

  /// The colour of getting somewhere: the finished picture, the next button.
  static const good = Color(0xFF2E6B5A);

  /// Laid over the puzzle when it comes out.
  ///
  /// Solid. The first version was a wash, on the theory that the finished
  /// picture should stay in sight behind the card — but the card shows the
  /// picture too, so what that actually produced was the same picture twice at
  /// two sizes, one of them ghosted, overlapping. One of them had to go and it
  /// was not going to be the one with the time under it.
  static const veil = Color(0xFFF4F0E6);
}
