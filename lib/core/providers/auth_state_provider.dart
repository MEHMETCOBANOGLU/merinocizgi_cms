// lib/core/providers/auth_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 1. Kullanıcının kimlik durumunu ve rollerini tutacak bir sınıf
class AuthState {
  final User? user;
  final bool isAdmin;
  final bool isEmailVerified;

  AuthState({
    this.user,
    this.isAdmin = false,
    this.isEmailVerified = false,
  });
}

// 2. Bu provider, AuthState'i yönetecek ana StateNotifier
class AuthStateNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthStateNotifier() : super(const AsyncValue.loading()) {
    // FirebaseAuth'daki değişiklikleri dinle
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  // Kullanıcı durumu değiştiğinde bu fonksiyon tetiklenir
  Future<void> _onAuthStateChanged(User? user) async {
    state = const AsyncValue.loading();

    if (user == null) {
      // Kullanıcı çıkış yaptı, tüm durumları sıfırla.
      state = AsyncValue.data(
          AuthState(user: null, isAdmin: false, isEmailVerified: false));
    } else {
      // Kullanıcı giriş yaptı veya durumu değişti.
      try {
        // KRİTİK: Firebase'den en güncel kullanıcı durumunu çek.
        // Bu, e-postayı doğruladıktan sonra durumun güncellenmesini sağlar.
        await user.reload();
        // Yenilenmiş kullanıcıyı tekrar al, çünkü 'user' nesnesi eski olabilir.
        final refreshedUser = FirebaseAuth.instance.currentUser;
        if (refreshedUser == null) {
          // Eğer bu arada bir sorun olduysa
          state = AsyncValue.data(
              AuthState(user: null, isAdmin: false, isEmailVerified: false));
          return;
        }

        final idTokenResult = await refreshedUser.getIdTokenResult(true);
        final bool isAdmin = idTokenResult.claims?['admin'] as bool? ?? false;

        // State'i, en güncel e-posta doğrulama bilgisiyle birlikte oluştur.
        state = AsyncValue.data(AuthState(
          user: refreshedUser,
          isAdmin: isAdmin,
          isEmailVerified: refreshedUser.emailVerified, // <-- YENİ
        ));
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    }
  }
}

// 3. Uygulamanın her yerinden erişebileceğimiz global ana provider
// Bu, hem User nesnesini hem de isAdmin bilgisini tek bir yerden yönetir.
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<AuthState>>((ref) {
  return AuthStateNotifier();
});

// 4. Sadece 'isAdmin' durumunu kolayca izlemek için bir Provider
// Bu provider, authStateProvider'ı dinler ve sadece 'isAdmin' değerini dışarıya verir.
// Bu sayede UI kodunda .value?.isAdmin ?? false gibi uzun ifadeler yazmaktan kurtuluruz.
final isAdminProvider = Provider<bool>((ref) {
  // authStateProvider'daki değişikliği izle (watch)
  final authState = ref.watch(authStateProvider);

  // authState'in içindeki 'value' (yani AsyncData) üzerinden isAdmin'e eriş.
  // Eğer state henüz data değilse (loading/error) veya data null ise, false döndür.
  return authState.value?.isAdmin ?? false;
});
