import 'rules.dart';

/// One ask: a moot to size, for what the sharing does.
class Level {
  const Level({
    required this.name,
    required this.hamlets,
    required this.pops,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The hamlets and their populations, in hundreds.
  final List<String> hamlets;
  final List<int> pops;

  /// 'alabama': one more seat costs a hamlet a seat under Hamilton;
  /// 'overQuota': Jefferson gives a hamlet more than its quota rounded
  /// up; 'whole': every quota is whole; 'jefferson': one more seat costs
  /// a hamlet a seat under Jefferson.
  final String kind;

  /// How many of the sham's moots land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  int get settings => Rules.sweep((s) => true).$2;

  bool get winnable => ways > 0;

  int get total => pops.fold(0, (a, b) => a + b);

  /// Whether a moot of [seats] lands the ask.
  bool meets(int seats) {
    switch (kind) {
      case 'alabama':
        return Rules.alabama(pops, seats);
      case 'overQuota':
        return Rules.overQuota(pops, seats);
      case 'whole':
        return Rules.wholeQuotas(pops, seats);
      default:
        return Rules.jeffersonFalls(pops, seats);
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    final list = pops.map((p) => '$p').toList();
    final who = 'hamlets of ${list.sublist(0, list.length - 1).join(', ')} and ${list.last} hundred';
    switch (kind) {
      case 'alabama':
        return 'size the moot of $who so that one more seat by largest remainders costs a hamlet a seat';
      case 'overQuota':
        return 'size the moot of $who so that dealing gives a hamlet more than its quota rounded up';
      case 'whole':
        return 'size the moot of $who so that every quota is a whole number of seats';
      default:
        return 'size the moot of $who so that one more seat by dealing costs a hamlet a seat';
    }
  }
}
