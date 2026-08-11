import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each consignment has stacked with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a
/// consignment nobody has stacked. Stranded stacks write nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'stacked.';

  static String _key(String consignment) => '$_prefix$consignment';

  int? askingsFor(String consignment) =>
      _prefs.getInt(_key(consignment));

  bool has(String consignment) => askingsFor(consignment) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a standing stack down, and says whether it beat what was
  /// there.
  Future<bool> record(String consignment, int askings) async {
    final before = askingsFor(consignment);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(consignment), askings);
    return true;
  }
}
