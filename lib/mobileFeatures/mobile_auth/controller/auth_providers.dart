// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // --- YENİ PROVIDER ---
// // Banner'ın görünürlük durumunu yöneten StateNotifier.
// class BannerNotifier extends StateNotifier<bool> {
//   BannerNotifier() : super(false); // Başlangıçta banner görünmez (false)

//   Timer? _timer;

//   // Banner'ı gösteren ve 3 saniye sonra otomatik olarak gizleyen metot.
//   void show() {
//     // Eğer zaten bir zamanlayıcı çalışıyorsa, onu iptal et.
//     _timer?.cancel();

//     // Banner'ı görünür yap.
//     state = true;

//     // 3 saniye sonra banner'ı gizlemek için yeni bir zamanlayıcı başlat.
//     _timer = Timer(const Duration(seconds: 3), () {
//       // Widget hala hayattaysa (dispose edilmediyse) state'i güncelle.
//       if (mounted) {
//         state = false;
//       }
//     });
//   }

//   // Widget dispose edildiğinde zamanlayıcıyı iptal et.
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
// }

// // Bu provider'ı UI'dan çağırmak ve izlemek için kullanacağız.
// final bannerVisibilityProvider =
//     StateNotifierProvider<BannerNotifier, bool>((ref) {
//   return BannerNotifier();
// });
