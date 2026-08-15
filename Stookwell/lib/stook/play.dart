import 'level.dart';
import 'rules.dart';

/// A harvest being stooked. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.stooks, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, const [], 0, null);

  /// A play stood at a standing, for the mark and the tests.
  factory Play.standing(Level level, List<int> stooks) =>
      Play._(level, List.of(stooks), stooks.fold(0, (a, b) => a + b), null);

  final Level level;

  /// The stooks in the order begun, each its count of sheaves.
  final List<int> stooks;

  /// Sheaves stood, counted.
  final int moves;

  final Play? before;

  /// The tap that begins a new stook.
  static const newStook = -1;

  int get stood => stooks.fold(0, (a, b) => a + b);

  int get pool => level.sheaves - stood;

  bool get full => pool == 0;

  /// The standing as a partition, largest stook first.
  List<int> get parts => List.of(stooks)..sort((a, b) => b - a);

  bool get isDone => full && level.meets(stooks);

  /// Every sheaf stood and the ask not met: over, not landed.
  bool get missed => full && !isDone;

  bool get gaveUp => !level.winnable && missed;

  bool get isOver => isDone || missed;

  bool touches(int where) =>
      !isOver && pool > 0 && (where == newStook || (where >= 0 && where < stooks.length));

  /// Taps a stook to stand one more sheaf in it, or the pool to begin
  /// a new stook with one.
  Play tap(int where) {
    if (!touches(where)) return this;
    final held = where == newStook
        ? [...stooks, 1]
        : [for (var i = 0; i < stooks.length; i++) i == where ? stooks[i] + 1 : stooks[i]];
    return Play._(level, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('back', 0) when the standing has
  /// strayed from the aim, ('add', stook) for one more sheaf in a stook,
  /// or ('new', 0) to begin the next; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    if (stooks.length > aim.length) return ('back', 0);
    for (var i = 0; i < stooks.length; i++) {
      if (stooks[i] > aim[i]) return ('back', 0);
      if (i + 1 < stooks.length && stooks[i] < aim[i]) return ('back', 0);
    }
    if (stooks.isNotEmpty && stooks.last < aim[stooks.length - 1]) return ('add', stooks.length - 1);
    return ('new', 0);
  }

  /// The walk's first landing partition, largest stook first, kept
  /// once found.
  static List<int>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      List<int>? found;
      Rules.partitions(level.sheaves, (parts) {
        if (found == null && level.meets(parts)) found = List.of(parts);
      });
      _aims[level.name] = found;
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<int>?>{};
}
