import 'cut.dart';
import 'rules.dart';

/// A ruler being cut. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.cut, this.rules, this.notched, this.moves, this.before);

  Play.of(Cut cut) : this._(cut, Rules(cut.length), const [], 0, null);

  final Cut cut;
  final Rules rules;

  /// The notches cut so far, in mark order.
  final List<int> notched;

  final int moves;

  final Play? before;

  static final _answers = <String, List<int>>{};

  /// One cutting meeting the ask, kept per ruler.
  List<int>? get answer {
    if (!cut.winnable) return null;
    return _answers[cut.name] ??= rules
        .soundCuttings(cut.notches, perfect: cut.perfect)
        .first;
  }

  bool hasNotch(int mark) => notched.contains(mark);

  List<int> get census => rules.census(notched);

  /// The lengths measured more than once.
  List<int> get doubled => [
        for (var distance = 1; distance <= cut.length; distance++)
          if (census[distance] > 1) distance,
      ];

  bool get isSound => doubled.isEmpty;

  bool get isDone {
    if (notched.length != cut.notches || !isSound) return false;
    if (!cut.perfect) return cut.winnable;
    return rules.isPerfect(notched);
  }

  /// Cuts or fills a notch.
  Play toggle(int mark) {
    if (isDone || mark < 0 || mark > cut.length) return this;
    if (!hasNotch(mark) && notched.length >= cut.notches) return this;
    final next = hasNotch(mark)
        ? [for (final held in notched) if (held != mark) held]
        : ([...notched, mark]..sort());
    return Play._(cut, rules, next, moves + 1, this);
  }

  bool get isFull => notched.length >= cut.notches;

  Play get back => before ?? this;

  /// The mend toward the kept answer: a notch to fill, or a mark to
  /// cut, or null when done or nothing meets the ask.
  int? get next {
    final wanted = answer;
    if (isDone || wanted == null) return null;
    for (final held in notched) {
      if (!wanted.contains(held)) return held;
    }
    for (final mark in wanted) {
      if (!hasNotch(mark)) return mark;
    }
    return null;
  }
}
