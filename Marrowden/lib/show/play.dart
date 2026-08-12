import 'rules.dart';
import 'show.dart';

/// A sitting in progress, and the tally of the bench so far. Every
/// state is a fresh value, and the one before hangs on for the
/// record.
class Play {
  Play._(this.show, this.deals, this.dealAt, this.shown, this.kept,
      this.won, this.played, this.before);

  /// [deals] is the run of sittings this bench will deal, one
  /// ordering after another; the screen builds it shuffled, a test
  /// hands it written out.
  factory Play.of(Show show, List<List<int>> deals) =>
      Play._(show, deals, 0, 1, null, 0, 0, null);

  final Show show;
  final List<List<int>> deals;

  /// Which sitting of [deals] is on the bench.
  final int dealAt;

  /// Marrows brought up so far this sitting.
  final int shown;

  /// The seat of the marrow taken, or null while judging.
  final int? kept;

  /// Sittings won and played on this bench.
  final int won;
  final int played;

  final Play? before;

  List<int> get deal => deals[dealAt % deals.length];

  /// The marrow up now: its seat.
  int get upAt => shown - 1;

  /// Whether the marrow up now is the best yet.
  bool get record {
    for (var seen = 0; seen < upAt; seen++) {
      if (deal[seen] > deal[upAt]) return false;
    }
    return true;
  }

  /// How the marrow up ranks among the seen: 1 is best yet.
  int get rank {
    var rank = 1;
    for (var seen = 0; seen < upAt; seen++) {
      if (deal[seen] > deal[upAt]) rank++;
    }
    return rank;
  }

  bool get judging => kept == null;

  /// The sitting's verdict, once taken.
  bool get sittingWon =>
      kept != null && deal[kept!] == show.marrows - 1;

  /// The last marrow must be taken.
  bool get mayWave => judging && shown < show.marrows;

  /// Take the marrow up now.
  Play take() {
    if (!judging) return this;
    final wins = deal[upAt] == show.marrows - 1 ? won + 1 : won;
    return Play._(show, deals, dealAt, shown, upAt, wins, played + 1,
        this);
  }

  /// Wave it by.
  Play wave() {
    if (!mayWave) return this;
    return Play._(
        show, deals, dealAt, shown + 1, null, won, played, this);
  }

  /// One step back within a sitting.
  Play get back => before ?? this;

  /// The next sitting up on the bench.
  Play nextDeal() {
    if (judging) return this;
    return Play._(
        show, deals, dealAt + 1, 1, null, won, played, this);
  }

  /// Whether the bench is done: the asked-for wins on a winnable
  /// bench; on the sure pick, the first miss ends it, and only a
  /// clean sweep of every sitting closes it won.
  bool get benchWon => show.winnable
      ? won >= Show.asked
      : played == deals.length && won == played;

  bool get benchLost => !show.winnable && won < played;

  bool get isOver => !judging && (benchWon || benchLost);

  /// Whether the rule takes the marrow up now.
  bool get ruleTakes =>
      Rules.takes(show.skip, shown, record, show.marrows);
}
