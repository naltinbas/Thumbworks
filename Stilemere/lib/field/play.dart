import 'level.dart';
import 'rules.dart';

/// A field being walked. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.walk, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, const [(0, 0)], 0, null);

  /// A play stood at a walk, for the mark and the tests.
  factory Play.standing(Level level, List<Junction> walk) =>
      Play._(level, List.of(walk), walk.length - 1, null);

  final Level level;

  /// The junctions walked, gate first.
  final List<Junction> walk;

  /// Steps taken forward, counted; a step back is not a move.
  final int moves;

  final Play? before;

  Field get field => level.field;

  Junction get head => walk.last;

  bool get atMill => head == field.mill;

  List<Junction> get stilesPassed => [for (final s in field.stiles) if (walk.contains(s)) s];

  bool get isDone => atMill && field.lands(walk);

  /// The mill reached with a stile missed: the walk is over, not landed.
  bool get missed => atMill && !isDone;

  bool get gaveUp => !level.winnable && missed;

  bool get isOver => isDone || missed;

  /// Whether the walk can go on at all from here.
  bool get stuck => !atMill && field.stepsFrom(head).isEmpty;

  /// The landings still on from here, by walking.
  int get landingsOn => isOver ? (isDone ? 1 : 0) : field.landingsFrom(walk);

  bool touches(Junction j) => !isOver && field.stepsFrom(head).contains(j);

  /// Steps to a neighbouring junction, right or up.
  Play tap(Junction j) {
    if (!touches(j)) return this;
    return Play._(level, [...walk, j], moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('back', head) when the walk has
  /// strayed from a landing route, or ('step', junction) for the next;
  /// null when nothing lands.
  (String, Junction)? get next {
    if (isOver || !level.winnable) return null;
    if (field.landingsFrom(walk) == 0) return ('back', head);
    // The first landing route on from here, right before up.
    List<Junction>? rest;
    field.walks((r) {
      if (rest == null && field.lands([...walk, ...r.skip(1)])) rest = List.of(r);
    }, from: head, mindPonds: true);
    return rest == null || rest!.length < 2 ? null : ('step', rest![1]);
  }
}
