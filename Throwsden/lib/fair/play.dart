import 'level.dart';
import 'rules.dart';

/// A yard being lined up. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.yard, this.line, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, Yard(level.wrestlers, level.bouts), const [], 0, null);

  /// A play stood at a line, for the mark and the tests.
  factory Play.standing(Level level, List<int> line) =>
      Play._(level, Yard(level.wrestlers, level.bouts), List.of(line), line.length, null);

  final Level level;
  final Yard yard;

  /// The wrestlers in line, first to last.
  final List<int> line;

  /// Wrestlers stepped in and out, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless yard admits it.
  static const gaveUpAt = 13;

  bool get full => line.length == level.wrestlers;

  /// Whether link [i], from line[i] to line[i + 1], holds.
  bool linkHolds(int i) => yard.beat(line[i], line[i + 1]);

  /// The first link that breaks, or null.
  int? get broken {
    for (var i = 0; i + 1 < line.length; i++) {
      if (!linkHolds(i)) return i;
    }
    return null;
  }

  int get linksHolding => [for (var i = 0; i + 1 < line.length; i++) if (linkHolds(i)) i].length;

  bool get chainHolds => broken == null;

  /// Whether the last threw the first, once the line is full.
  bool get ringCloses => full && yard.beat(line.last, line.first);

  bool get isDone => full && chainHolds && (!level.ring || ringCloses);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  List<int> get bench => [for (var w = 0; w < level.wrestlers; w++) if (!line.contains(w)) w];

  bool touches(int w) => !isOver && w >= 0 && w < level.wrestlers && (!line.contains(w) || line.last == w);

  /// Taps a wrestler: steps him into the line at the end, or steps the
  /// last one out.
  Play tap(int w) {
    if (!touches(w)) return this;
    final held = line.contains(w) ? line.sublist(0, line.length - 1) : [...line, w];
    return Play._(level, yard, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('out', wrestler) for the last in
  /// line when the line has strayed from the aim, or ('in', wrestler)
  /// for the next; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (var i = 0; i < line.length; i++) {
      if (line[i] != aim[i]) return ('out', line.last);
    }
    return line.length < aim.length ? ('in', aim[line.length]) : null;
  }

  /// The walk's first landing ordering, kept once found.
  static List<int>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = Yard(level.wrestlers, level.bouts).landing(ring: level.ring);
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<int>?>{};
}
