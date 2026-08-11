import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each day has been booked with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a day
/// nobody has kept. The extra guest writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'booked.';

  static String _key(String day) => '$_prefix$day';

  int? askingsFor(String day) => _prefs.getInt(_key(day));

  bool has(String day) => askingsFor(day) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a filled book down, and says whether it beat what was
  /// there.
  Future<bool> record(String day, int askings) async {
    final before = askingsFor(day);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(day), askings);
    return true;
  }
}
