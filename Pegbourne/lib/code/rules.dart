/// The law of the pegs.
///
/// A code is four pegs, each one of four colours. A guess against a
/// code earns marks: a black mark for every peg of the right colour
/// in the right place, and a white mark for every further peg of a
/// right colour standing in the wrong place.
///
/// A riddle is a handful of old guesses with their marks written
/// down. The answer is a code that earns every row exactly its
/// written marks, and a sweep of all 256 codes counts how many do.
class Rules {
  static const pegs = 4;
  static const colours = 4;
  static const codes = 256;

  /// A code packed two bits a peg.
  static int pegAt(int code, int slot) => (code >> (slot * 2)) & 3;

  static int packed(List<int> pegList) {
    var code = 0;
    for (var slot = 0; slot < pegs; slot++) {
      code |= pegList[slot] << (slot * 2);
    }
    return code;
  }

  /// The marks a guess earns against a code: blacks and whites.
  static (int, int) marks(int code, int guess) {
    var black = 0;
    final codeLeft = List<int>.filled(colours, 0);
    final guessLeft = List<int>.filled(colours, 0);
    for (var slot = 0; slot < pegs; slot++) {
      final want = pegAt(code, slot);
      final got = pegAt(guess, slot);
      if (want == got) {
        black++;
      } else {
        codeLeft[want]++;
        guessLeft[got]++;
      }
    }
    var white = 0;
    for (var colour = 0; colour < colours; colour++) {
      white += codeLeft[colour] < guessLeft[colour]
          ? codeLeft[colour]
          : guessLeft[colour];
    }
    return (black, white);
  }

  /// Whether a code earns a row exactly its written marks.
  static bool agrees(int code, (int, int, int) row) {
    final (guess, black, white) = row;
    return marks(code, guess) == (black, white);
  }

  /// Every code agreeing with every row.
  static List<int> answers(List<(int, int, int)> rows) => [
        for (var code = 0; code < codes; code++)
          if (rows.every((row) => agrees(code, row))) code,
      ];

  /// A pair of rows no code satisfies together, or null.
  static ((int, int, int), (int, int, int))? irreconcilable(
      List<(int, int, int)> rows) {
    for (var one = 0; one < rows.length; one++) {
      for (var other = one + 1; other < rows.length; other++) {
        var any = false;
        for (var code = 0; code < codes; code++) {
          if (agrees(code, rows[one]) && agrees(code, rows[other])) {
            any = true;
            break;
          }
        }
        if (!any) return (rows[one], rows[other]);
      }
    }
    return null;
  }
}
