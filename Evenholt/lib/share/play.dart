import 'rules.dart';
import 'share.dart';

/// A share being dealt. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.share, this.rules, this.right, this.moves, this.before);

  factory Play.of(Share share) => Play._(
      share,
      Rules(share.count, share.degrees),
      List.filled(share.count, false),
      0,
      null);

  /// A play stood at a share, for the mark and the tests.
  factory Play.standing(Share share, List<bool> right) => Play._(
      share, Rules(share.count, share.degrees), List.of(right), 1, null);

  final Share share;
  final Rules rules;

  /// Which tray each token sits on: true for the right tray,
  /// token t at index t - 1.
  final List<bool> right;

  /// Tokens carried across, counted every way.
  final int moves;

  final Play? before;

  /// The line past which the hopeless share admits it.
  static const gaveUpAt = 8;

  bool get isDone => rules.lands(right);

  bool get gaveUp => !share.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  List<int> get leftTray => [
        for (var token = 1; token <= share.count; token++)
          if (!right[token - 1]) token,
      ];

  List<int> get rightTray => [
        for (var token = 1; token <= share.count; token++)
          if (right[token - 1]) token,
      ];

  /// The two trays' power sums for one degree.
  (int, int) sums(int degree) => (
        rules.powerSum(right, side: false, degree: degree),
        rules.powerSum(right, side: true, degree: degree),
      );

  List<bool> get agreeing => rules.agreeing(right);

  bool touches(int token) => !isOver && token >= 1 && token <= share.count;

  /// Carries a token across to the other tray.
  Play tap(int token) {
    if (!touches(token)) return this;
    final held = List.of(right);
    held[token - 1] = !held[token - 1];
    return Play._(share, rules, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The token the show-me points at: the first one on the wrong
  /// tray against the sweep's landing, read with token 1's tray
  /// as the player has it; null when nothing lands.
  int? get next {
    if (isOver || !share.winnable) return null;
    final aim = rules.landing();
    if (aim == null) return null;
    final flip = right[0];
    for (var token = 1; token <= share.count; token++) {
      if ((aim[token - 1] != flip) != right[token - 1]) return token;
    }
    return null;
  }
}
