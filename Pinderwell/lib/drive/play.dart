import 'cold.dart';
import 'field.dart';

/// A drive part way through: where the ewe stands, and whose fee it still is.
class Play {
  const Play._(
    this.field,
    this.east,
    this.north,
    this.made,
    this.mine,
    this.theirFrom,
    this.before,
  );

  Play.of(Field field)
      : this._(field, field.east, field.north, 0, false, null, null);

  final Field field;

  /// Where the ewe stands now.
  final int east;
  final int north;

  /// Pushes of the player's own so far.
  final int made;

  /// Whether the last push into the pen was the player's. Meaningless until
  /// the ewe is penned.
  final bool mine;

  /// Where the ewe stood before the pinder's last push, for drawing it, or
  /// null when he has not pushed since.
  final (int, int)? theirFrom;

  /// The drive as it stood before the player's last push, for taking back
  /// the whole exchange, or null at the start.
  final Play? before;

  bool get isOver => east == 0 && north == 0;

  bool get won => isOver && mine;

  /// Whether the player, pushing next, still forces the pen against the
  /// best pinder there is.
  bool get winnable => !isOver && !Cold.isCold(east, north);

  /// The fewest pushes of the player's own this drive can still end in, or
  /// null once the ewe is the pinder's whatever happens.
  int? get couldFinishIn {
    if (isOver) return won ? made : null;
    final more = Cold.fewestFrom(east, north);
    return more == null ? null : made + more;
  }

  /// Whether the ewe can be pushed to there from where she stands: due
  /// west, due south, or the same paces of both.
  bool mayPush(int toEast, int toNorth) {
    if (isOver || toEast < 0 || toNorth < 0) return false;
    final west = east - toEast;
    final south = north - toNorth;
    if (west < 0 || south < 0 || (west == 0 && south == 0)) return false;
    return west == 0 || south == 0 || west == south;
  }

  /// The player's push, and the pinder's answer on its heels. Returns this
  /// unchanged when the ewe cannot be pushed there.
  Play touch(int toEast, int toNorth) {
    if (!mayPush(toEast, toNorth)) return this;
    if (toEast == 0 && toNorth == 0) {
      return Play._(field, 0, 0, made + 1, true, null, this);
    }
    final (answerEast, answerNorth) = Cold.reply(toEast, toNorth);
    return Play._(
      field,
      answerEast,
      answerNorth,
      made + 1,
      false,
      (toEast, toNorth),
      this,
    );
  }

  /// The whole last exchange back: the player's push and the answer to it.
  Play get back => before ?? this;

  /// The winning push from here, or null when there is none to be had.
  (int, int)? get next => Cold.next(east, north);
}
