import 'call.dart';

/// One table at the Pennygill: who calls when, and for how many rounds.
class Wager {
  const Wager({
    required this.name,
    required this.stakes,
    this.theyCallFirst = false,
    this.evenTable = false,
    this.forced,
    this.theirFixedCall,
    this.note,
  });

  final String name;

  /// Rounds to take the match.
  final int stakes;

  /// Whether the house calls first and you reply.
  final bool theyCallFirst;

  /// Whether the house answers with your opposite, the one fair reply.
  final bool evenTable;

  /// A call you are held to, or null for a free choice.
  final Call? forced;

  /// The house's call on tables where it calls first.
  final Call? theirFixedCall;

  /// A sentence of its own this table has earned, said after the why, or
  /// null for the tables whose story is the usual one.
  final String? note;

  Call get theirCall => theirFixedCall ?? const Call(2);
}
