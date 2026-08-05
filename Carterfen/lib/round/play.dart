import 'moor.dart';
import 'rounds_list.dart';
import 'shortest.dart';

/// A round being driven.
///
/// The order the places have been called at, and nothing else. How far it has
/// been, what is left and how it compares with the shortest all come out of
/// that and the map.
class Play {
  const Play._(this.round, this.moor, this.called);

  factory Play.of(Round round) => Play._(round, round.moor, const [0]);

  final Round round;
  final Moor moor;

  /// The places called at, in order, starting at the yard.
  final List<int> called;

  int get count => moor.count;

  /// Where the cart is now.
  int get at => called.last;

  bool hasCalled(int stop) => called.contains(stop);

  /// The places not called at yet.
  List<int> get left => [
        for (var stop = 0; stop < count; stop++)
          if (!called.contains(stop)) stop,
      ];

  /// How far it has driven so far, not counting the way home.
  int get gone {
    var total = 0;
    for (var i = 1; i < called.length; i++) {
      total += moor.between(called[i - 1], called[i]);
    }
    return total;
  }

  /// How far the whole round is, once every place has been called at and the
  /// cart is home.
  int get length => isDone ? gone + moor.between(at, 0) : 0;

  bool get isDone => called.length == count;

  /// How much further than the shortest this round is.
  int get over => isDone ? length - round.shortest : 0;

  bool get isShortest => isDone && length == round.shortest;

  /// Whether the cart may go to a place: anywhere it has not been.
  bool canGoTo(int stop) =>
      stop >= 0 && stop < count && !called.contains(stop);

  /// This round with the cart driven to a place.
  Play goTo(int stop) {
    if (!canGoTo(stop)) return this;
    return Play._(round, moor, [...called, stop]);
  }

  /// This round with the last call taken back.
  Play get back {
    if (called.length < 2) return this;
    return Play._(round, moor, called.sublist(0, called.length - 1));
  }

  Play get again => Play.of(round);

  /// The shortest round from here: the way to call at everything left and get
  /// home, given where the cart has already been.
  ///
  /// It is the same working as the whole answer, over the places left, so a
  /// hint half way through a bad round is honest about the round being
  /// driven rather than the one that was on offer at the start.
  Shortest get restOfIt => Rounder(moor).through(at, left, 0);

  /// The place to drive to next to finish as short as it can still be.
  int? get next {
    if (isDone) return null;
    return restOfIt.order[1];
  }
}
