import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/app_router.dart';
import 'package:merinocizgi/core/di.dart';
import 'package:merinocizgi/core/theme/index.dart';
import 'package:merinocizgi/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  configureDependencies(); // ← bütün bağımlılıkları burada kaydettik
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
    );
  }
}
