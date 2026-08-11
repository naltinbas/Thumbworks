import 'day.dart';
import 'rules.dart';

/// A book being kept. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.day, this.rules, this.booked, this.moves, this.before);

  Play.of(Day day)
      : this._(day, Rules(day.starts, day.ends), 0, 0, null);

  final Day day;
  final Rules rules;

  /// The booked hirings, as bits.
  final int booked;

  /// Bookings and cancellings made so far.
  final int moves;

  final Play? before;

  static final _answers = <String, int>{};

  /// One full book, by the early-finish rule, kept per day.
  int get answer => _answers[day.name] ??= rules.byEarlyFinish();

  bool isBooked(int hiring) => booked & (1 << hiring) != 0;

  int get bookedCount => Rules.weigh(booked);

  /// The clashing pairs among the booked.
  List<(int, int)> get clashes => [
        for (var one = 0; one < day.hirings; one++)
          for (var other = one + 1; other < day.hirings; other++)
            if (isBooked(one) && isBooked(other) && rules.clash(one, other))
              (one, other),
      ];

  bool get isDone =>
      bookedCount == day.ask && clashes.isEmpty && day.winnable;

  /// Books or cancels a hiring.
  Play toggle(int hiring) {
    if (isDone || hiring < 0 || hiring >= day.hirings) return this;
    return Play._(
        day, rules, booked ^ (1 << hiring), moves + 1, this);
  }

  Play get back => before ?? this;

  /// The mend toward the early-finish book: a hiring to cancel, or
  /// one to book, or null when done or the day cannot hold the ask.
  int? get next {
    if (isDone || !day.winnable) return null;
    for (var hiring = 0; hiring < day.hirings; hiring++) {
      if (isBooked(hiring) && answer & (1 << hiring) == 0) {
        return hiring;
      }
    }
    for (var hiring = 0; hiring < day.hirings; hiring++) {
      if (!isBooked(hiring) && answer & (1 << hiring) != 0) {
        return hiring;
      }
    }
    return null;
  }
}
