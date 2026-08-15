import 'geometry.dart';
import 'rules.dart';

/// One frame on the sham: which cut square's pieces, what frame to lay
/// them in, what is allowed, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.side,
    required this.width,
    required this.height,
    required this.overlapAllowed,
    required this.mustFill,
    required this.ways,
    required this.layings,
    this.note,
  });

  final String name;

  /// The side of the square the pieces were cut from.
  final int side;

  /// The frame to lay them in.
  final int width;
  final int height;

  /// How many squares the pieces may share, all told.
  final int overlapAllowed;

  /// Whether the frame must be filled, no square left bare.
  final bool mustFill;

  /// Layings meeting the ask, by the sweep; nought for the hopeless.
  final int ways;

  /// Layings of the four pieces inside the frame, all of them.
  final int layings;

  /// One thing worth knowing about this frame, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => Rules(side: side, width: width, height: height);

  Q get overlapAllowed2 => Q(2 * overlapAllowed);

  static const _words = {3: 'three', 5: 'five', 8: 'eight', 13: 'thirteen', 21: 'twenty-one'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task {
    final ask = overlapAllowed == 0
        ? (mustFill ? 'with no overlap and no square left bare' : 'with no overlap')
        : 'overlapping by no more than $overlapAllowed square${overlapAllowed == 1 ? '' : 's'}';
    return 'lay the four pieces of the ${word(side)}-square in the ${word(width)}-by-${word(height)} frame $ask';
  }
}
