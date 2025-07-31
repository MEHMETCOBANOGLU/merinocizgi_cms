import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/app_router.dart';
import 'package:merinocizgi/core/di.dart';
import 'package:merinocizgi/core/theme/index.dart';
import 'package:merinocizgi/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:merinocizgi/mobileFeatures/mobile_settings/controller/settings_controller.dart';
import 'package:merinocizgi/mobileFeatures/shared/controller/deeplink_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase başarıyla başlatıldı.");
  } catch (e) {
    // Eğer Firebase başlatılamazsa, bu kritik bir hatadır.
    print("❌ Firebase başlatılırken HATA oluştu: $e");
  }
  final settings = SettingsController();
  await settings.loadSettings(); // uygulama başlamadan ayarları uygula

  configureDependencies(); // ← bütün bağımlılıkları burada kaydettik
  await DeeplinkHandler.init(); // 👈 önce URI yakala

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'MerinoÇizgi',
      debugShowCheckedModeBanner: false,
      theme: kIsWeb ? AppTheme.lightTheme : AppTheme.darkTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,

      // 👇 quill için gerekli ayarlar (bölüm düzenlemedeki font vs ayarları) 👇
      supportedLocales: const [
        Locale('en'), // English (add others if needed)
        Locale('tr'), // Turkish
      ],
      localizationsDelegates: const [
        FlutterQuillLocalizations
            .delegate, // Crucial addition for flutter_quill
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
