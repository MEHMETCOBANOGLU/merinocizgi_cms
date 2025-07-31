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
  
  // Initialize deep link handler early
  await DeeplinkHandler.init();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // Check for pending deep links after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeeplinkHandler.checkAndNavigate(context);
    });

    return MaterialApp.router(
      title: 'MerinoÇizgi',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: kIsWeb ? AppTheme.lightTheme : AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}