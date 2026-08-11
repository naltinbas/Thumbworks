import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each plot has been finished with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a plot
/// nobody has shaded. The short tally writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'shaded.';

  static String _key(String plot) => '$_prefix$plot';

  int? askingsFor(String plot) => _prefs.getInt(_key(plot));

  bool has(String plot) => askingsFor(plot) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a finished plot down, and says whether it beat what was
  /// there.
  Future<bool> record(String plot, int askings) async {
    final before = askingsFor(plot);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(plot), askings);
    return true;
  }
}
