import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_controller.dart';

final settingsControllerProvider = Provider<SettingsController>((ref) {
  final controller = SettingsController();
  controller.loadSettings(); // app başında ayarları yükle
  return controller;
});
