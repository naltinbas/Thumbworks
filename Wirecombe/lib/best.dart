import 'package:shared_preferences/shared_preferences.dart';

/// The fewest dial turns each stile has ever been landed in,
/// kept on the phone.
class Best {
  static SharedPreferences? _kept;

  static Future<void> ready() async {
    _kept ??= await SharedPreferences.getInstance();
  }

  static String _key(String name) => 'wirecombe.fewest.$name';

  static int? fewest(String name) => _kept?.getInt(_key(name));

  /// Keeps [dials] if it beats the standing record. True when it did.
  static Future<bool> landed(String name, int dials) async {
    await ready();
    final standing = fewest(name);
    if (standing != null && standing <= dials) return false;
    await _kept!.setInt(_key(name), dials);
    return true;
  }
}
