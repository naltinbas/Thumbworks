import 'rules.dart';

/// One ask: the villagers and what each of them says.
class Level {
  const Level({
    required this.name,
    required this.tellings,
    required this.ways,
    required this.note,
  });

  final String name;

  /// What each villager says, in order.
  final List<List<dynamic>> tellings;

  /// How many namings hold every telling, from the sweep.
  final int ways;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  int get villagers => tellings.length;

  int get namings => Rules.howManyNamings(villagers);

  /// Whether [naming] lands the ask.
  bool meets(List<bool> naming) =>
      naming.length == villagers && Rules.consistent(tellings, naming);

  /// The namings that hold, from the sweep.
  List<List<bool>> get answers => Rules.answers(tellings);

  /// The naming the pointer works towards: the one nearest to calling
  /// everybody a knight, which is how an ask opens.
  List<bool>? get aim {
    final found = answers;
    if (found.isEmpty) return null;
    var best = found.first;
    var least = -1;
    for (final naming in found) {
      final turns = naming.where((kind) => kind == Rules.knave).length;
      if (least < 0 || turns < least) {
        least = turns;
        best = naming;
      }
    }
    return best;
  }

  /// The taps it takes to reach it from calling everybody a knight.
  int? get fewest =>
      aim?.where((kind) => kind == Rules.knave).length;

  /// The task, told in words for the ledger.
  String get task =>
      'name the $villagers villagers so that every telling holds';
}
