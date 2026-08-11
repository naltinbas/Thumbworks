import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each room has been floored with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a room
/// nobody has planked. The clipped parlour writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'floored.';

  static String _key(String room) => '$_prefix$room';

  int? askingsFor(String room) => _prefs.getInt(_key(room));

  bool has(String room) => askingsFor(room) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a laid floor down, and says whether it beat what was
  /// there.
  Future<bool> record(String room, int askings) async {
    final before = askingsFor(room);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(room), askings);
    return true;
  }
}
