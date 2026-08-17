import 'rules.dart';

/// One ask: how far the far wall leans, and what is wanted of the peg
/// and the hall.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.lean,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'whole': every distance a whole number of paces; 'same': all four
  /// alike; 'fifty': the sums both fifty; 'inside': every distance
  /// whole with the peg inside the hall; 'agree': the two sums equal on
  /// a leaned hall, which never happens.
  final String kind;

  /// How far the far wall leans over: nought for a square-cornered
  /// hall.
  final int lean;

  /// How many standings land it, from the sweep.
  final int ways;

  /// The cheapest standing that lands it, from the sweep, as the hall
  /// and the peg; null when nothing does.
  final (int, int, int, int)? aim;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// The hall and the peg an ask opens on.
  static const openWide = 4, openTall = 3, openX = 2, openY = 2;

  /// Whether the hall [wide] by [tall] with the peg at [px], [py] lands
  /// the ask.
  bool meets(int wide, int tall, int px, int py) {
    if (!Rules.validHall(wide, tall) || !Rules.onField(px, py)) return false;
    switch (kind) {
      case 'whole':
        return Rules.allWhole(wide, tall, lean, px, py);
      case 'same':
        return Rules.allSame(wide, tall, lean, px, py);
      case 'fifty':
        return Rules.acrossOne(wide, tall, lean, px, py) == 50;
      case 'inside':
        return Rules.allWhole(wide, tall, lean, px, py) &&
            Rules.inside(wide, tall, lean, px, py);
      default:
        return Rules.apart(wide, tall, lean, px, py) == 0;
    }
  }

  /// The taps it takes to reach a standing from the opening: one for
  /// each pace the dials move, and one to stand the peg somewhere new.
  int taps(int wide, int tall, int px, int py) =>
      (wide - openWide).abs() +
      (tall - openTall).abs() +
      (px == openX && py == openY ? 0 : 1);

  /// The taps the cheapest standing takes.
  int? get fewest {
    final want = aim;
    return want == null ? null : taps(want.$1, want.$2, want.$3, want.$4);
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'whole':
        return 'stand the peg so that all four posts are a whole number of '
            'paces off';
      case 'same':
        return 'stand the peg so that all four posts are the same distance '
            'off';
      case 'fifty':
        return 'stand the peg so that each pair of opposite posts adds to '
            'fifty';
      case 'inside':
        return 'stand the peg inside the hall with all four posts a whole '
            'number of paces off';
      default:
        return 'stand the peg so that the two sums agree on a hall leaned '
            'over by $lean';
    }
  }
}
