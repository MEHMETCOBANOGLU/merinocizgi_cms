import 'package:shared_preferences/shared_preferences.dart';
import 'package:screen_brightness/screen_brightness.dart';

class SettingsController {
  static const _brightnessKey = 'app_brightness';

  double _brightness = 0.5; // varsayılan
  double get brightness => _brightness;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _brightness = prefs.getDouble(_brightnessKey) ?? 0.5;
    await ScreenBrightness().setApplicationScreenBrightness(_brightness);
  }

  Future<void> updateBrightness(double value) async {
    _brightness = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_brightnessKey, value);
    await ScreenBrightness().setApplicationScreenBrightness(value);
  }
}
