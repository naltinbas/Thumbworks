import 'level.dart';
import 'rules.dart';

/// A cellar being searched. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.from, this.size, this.asked, this.answers, this.before);

  factory Play.of(Level level) => Play._(level, 0, level.casks, 0, const [], null);

  /// A play stood at a search, for the mark and the tests: the casks
  /// from [from], [size] of them, after [asked] questions.
  factory Play.standing(Level level, int from, int size, int asked) => Play._(level, from, size, asked, const [], null);

  final Level level;

  /// The first cask that might hold the coin, counting from nought.
  final int from;

  /// How many casks might, from there.
  final int size;

  /// Questions asked.
  final int asked;

  /// What the cellarman answered, question by question: true for the
  /// right part.
  final List<bool> answers;

  final Play? before;

  int get to => from + size - 1;

  bool mightHold(int cask) => cask >= from && cask <= to;

  bool get found => size == 1;

  bool get isDone => found && asked <= level.questions;

  bool get spent => asked >= level.questions;

  /// The questions spent and the coin not found, on a cellar that could
  /// have been searched.
  bool get missed => level.winnable && spent && !found;

  bool get gaveUp => !level.winnable && spent && !found;

  bool get isOver => found || spent;

  /// The fewest questions that still find the coin from here, whatever
  /// the cellarman answers.
  int get stillNeeded => Rules.questions(size);

  /// Asks after cask [cut] of the row that might, counting from its
  /// first: the cellarman keeps the bigger part.
  Play cut(int cut) {
    if (isOver || cut < 1 || cut >= size) return this;
    final (bigger, right) = Rules.kept(size, cut);
    return Play._(level, right ? from + cut : from, bigger, asked + 1, [...answers, right], this);
  }

  /// Asks after the cask [at] on the whole row, for the taps.
  Play cutAt(int at) => cut(at - from + 1);

  Play get back => before ?? this;

  /// What the show-me points at: the cut after which the questions left
  /// still suffice, the middle for choice; null when nothing lands.
  int? get next {
    if (isOver || !level.winnable || stillNeeded > level.questions - asked) return null;
    final mid = Rules.middle(size);
    return mid;
  }
}
