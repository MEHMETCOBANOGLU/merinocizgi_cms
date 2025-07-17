// lib/features/auth/controller/auth_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/features/auth/controller/auth_methods.dart';

// Bu provider, AuthController'ın bir örneğini oluşturur ve yönetir.
// UI, bu provider aracılığıyla AuthController'a erişecek.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserCredential?>>((ref) {
  return AuthController(ref);
});

// Kimlik doğrulama işlemlerini yöneten ana sınıf.
class AuthController extends StateNotifier<AsyncValue<UserCredential?>> {
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthController(this._ref) : super(const AsyncData(null));

  /// E-posta ve şifre ile kullanıcı girişi yapar.
  Future<void> signInWithEmail(
      {required String email, required String password}) async {
    state = const AsyncLoading(); // İşlemin başladığını belirt.
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      state = AsyncData(userCredential); // Başarılı, sonucu state'e yaz.
    } on FirebaseAuthException catch (e, st) {
      // Hata oluştu, state'i güncelle ve hatayı UI'a ilet.
      state = AsyncError(_mapAuthExceptionToMessage(e), st);
      // Hatanın kendisini de yeniden fırlatabiliriz, böylece UI daha fazla detay alabilir.
      rethrow;
    }
  }

  /// Yeni bir kullanıcı kaydı oluşturur, Firestore'a kaydeder ve doğrulama e-postası gönderir.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String mahlas,
  }) async {
    state = const AsyncLoading();
    try {
      // 1. Firebase Auth'da kullanıcıyı oluştur.
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = userCredential.user;

      if (user != null) {
        // 2. Kullanıcı bilgilerini Firestore'a kaydet.
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'mahlas': mahlas,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': user.uid,
          'profileImageUrl': user.photoURL, // Başlangıçta null olabilir.
        });

        // 3. E-posta doğrulama linki gönder. (Kritik Adım)
        // Hata verse bile akışı durdurmamak için try-catch içine alabiliriz.
        try {
          await user.sendEmailVerification();
        } catch (e) {
          // Loglama yapılabilir, ama kullanıcıya hata göstermeye gerek yok.
          print("Doğrulama e-postası gönderilirken hata: $e");
        }
      }
      state = AsyncData(userCredential);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(_mapAuthExceptionToMessage(e), st);
      rethrow;
    }
  }

  /// Google ile girişi yönetir ve kullanıcı yoksa Firestore'a kaydeder.
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      // auth_methods.dart dosyasındaki metodu çağırıyoruz.
      final userCredential = await signInWithGoogleMethod();
      final user = userCredential.user;

      if (user != null) {
        // Sadece yeni kullanıcı ise Firestore'a yaz. (isNewUser kontrolü)
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'mahlas': '', // Google'dan mahlas gelmez, başlangıçta boş.
            'createdAt': FieldValue.serverTimestamp(),
            'uid': user.uid,
            'profileImageUrl': user.photoURL,
          });
        }
      }
      state = AsyncData(userCredential);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(_mapAuthExceptionToMessage(e), st);
      rethrow;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Şifre sıfırlama e-postası gönderir.
  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AsyncLoading();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = const AsyncData(null); // Başarılı ama credential döndürmez.
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(_mapAuthExceptionToMessage(e), st);
      rethrow;
    }
  }

  /// Facebook ile girişi yönetir ve kullanıcı yoksa Firestore'a kaydeder.
  Future<void> signInWithFacebook() async {
    state = const AsyncLoading();
    try {
      final userCredential = await signInWithFacebookMethod();
      // Yeni kullanıcı ise Firestore'a yazma işlemini de yapalım
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        final user = userCredential.user!;
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'mahlas': user.displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': user.uid,
          'profileImageUrl': user.photoURL,
        });
      }
      state = AsyncData(userCredential);
    } on FirebaseAuthException catch (e, st) {
      print(e);
      state = AsyncError(_mapAuthExceptionToMessage(e), st);
      rethrow;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Firebase'in teknik hata kodlarını, kullanıcı dostu Türkçe mesajlara çevirir.
  ///
  String _mapAuthExceptionToMessage(FirebaseAuthException e) {
    // --- DEBUG İÇİN GEÇİCİ LOGLAMA ---
    // Gerçek hata kodunu ve mesajını konsola yazdır.
    // Bu, hangi case'i eklememiz gerektiğini bize söyleyecek.
    print('🔥🔥🔥 FirebaseAuth HATA KODU: ${e.code}');
    print('🔥🔥🔥 Firebase Orijinal Mesaj: ${e.message}');
    // --- DEBUG İÇİN GEÇİCİ LOGLAMA SONU ---

    switch (e.code) {
      case 'invalid-email':
        return 'Lütfen geçerli bir e-posta adresi girin.';
      case 'user-not-found':
        return 'Bu e-posta adresine kayıtlı bir kullanıcı bulunamadı.';
      case 'wrong-password':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Girdiğiniz şifre yanlış.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten başka bir hesap tarafından kullanılıyor.';
      case 'weak-password':
        return 'Şifreniz çok zayıf. Lütfen en az 6 karakterli daha güçlü bir şifre seçin.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi şu anda aktif değil.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';

      // --- GOOGLE GİRİŞİ İLE İLGİLİ OLASI EKSİK CASE'LER ---
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresiyle daha önce başka bir yöntemle (örn: E-posta/Şifre) giriş yapılmış. Lütfen o yöntemle giriş yapın.';
      case 'user-cancelled':
        return 'Giriş işlemi sizin tarafınızdan iptal edildi.';
      case 'popup-closed-by-user':
        return 'Giriş penceresi kapatıldı. Lütfen tekrar deneyin.';
      case 'facebook-login-failed':
        return 'Facebook ile giriş yapılamadı. Lütfen tekrar deneyin.';

      default:
        // Eğer hata kodu hala yakalanamıyorsa, orijinal mesajı göstermek daha iyi olabilir.
        {
          print('FirebaseAuthException: ${e.code}  - $e  - ${e.message}');
        }
        return 'Bir hata oluştuu: ${e ?? 'Bilinmeyen hata.'}';
    }
  }
}
