import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';

class AccountController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  AccountController(this._ref) : super(const AsyncData(null));

  Future<bool> updateProfile({
    required String mahlas,
    Uint8List? newProfileImage,
  }) async {
    // İşlem başladığında durumu 'loading' yap.
    state = const AsyncLoading();

    try {
      // Yeni yapıya göre user nesnesini alıyoruz.
      final user = _ref.read(authStateProvider).value?.user;
      if (user == null) {
        throw Exception("Güncelleme için oturum açılmalıdır.");
      }

      // Firestore'a gönderilecek veriyi tutan map.
      final Map<String, dynamic> dataToUpdate = {
        'mahlas': mahlas,
      };

      // Eğer yeni bir resim seçildiyse...
      if (newProfileImage != null) {
        // 1. Firebase Storage'a yükle. Dosya adını user.uid yapmak en iyisidir.
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}.jpg');
        final uploadTask = await storageRef.putData(newProfileImage);

        // 2. Yüklenen resmin indirme URL'sini al.
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // 3. Bu URL'yi güncellenecek veriye ekle.
        dataToUpdate['profileImageUrl'] = downloadUrl;
      }

      // Firestore'daki kullanıcı dökümanını güncelle.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(dataToUpdate);

      // --- ÇOK ÖNEMLİ ---
      // Veri güncellendiği için, eski veriyi tutan `userProfileProvider`'ı geçersiz kıl.
      // Bu, provider'ın veriyi yeniden çekmesini ve UI'ın otomatik güncellenmesini sağlar.
      _ref.invalidate(userProfileProvider);

      // İşlem bittiğinde durumu tekrar 'başarılı' yap.
      state = const AsyncData(null);
      return true; // UI'a işlemin başarılı olduğunu bildir.
    } catch (e, st) {
      // Hata durumunda durumu 'error' yap.
      state = AsyncError(e, st);
      return false; // UI'a işlemin başarısız olduğunu bildir.
    }
  }

  // ---HESABI SİLME ---
  /// Kullanıcının hesabını ve ilgili tüm verilerini kalıcı olarak siler.
  /// Güvenlik için şifre doğrulaması gerektirir.
  Future<String?> deleteAccount(String password) async {
    state = const AsyncLoading();
    final user = _ref.read(authStateProvider).value?.user;

    if (user == null) {
      state = AsyncError(
          Exception("Kullanıcı oturumu bulunamadı."), StackTrace.current);
      return "Oturum bulunamadı. Lütfen tekrar giriş yapın.";
    }

    // Geri döndürülecek hata mesajı için bir değişken
    String? errorMessage;

    try {
      // 1. ADIM: KULLANICIYI YENİDEN DOĞRULAMA
      // Bu, işlemin hassasiyeti nedeniyle zorunlu bir güvenlik adımıdır.
      // Kullanıcının gerçekten kendisi olduğunu teyit ederiz.
      final cred =
          EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);

      // 2. ADIM: FIRESTORE'DAN KULLANICI VERİLERİNİ SİLME (OPSİYONEL AMA ÖNERİLİR)
      // Kullanıcının 'users' koleksiyonundaki dökümanını silebiliriz.
      // Not: Yazarın serileri ve bölümleri ne olacak? Onları da silmek veya anonim hale getirmek için
      // bir Cloud Function yazmak en doğrusudur. Şimdilik sadece profilini silelim.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // 3. ADIM: AUTHENTICATION'DAN KULLANICIYI SİLME (ANA İŞLEM)
      // Bu işlem kullanıcıyı Firebase Auth sisteminden kalıcı olarak kaldırır.
      await user.delete();

      state = const AsyncData(null); // İşlem başarılı
      return null; // Hata yoksa null döndür
    } on FirebaseAuthException catch (e, st) {
      // Yeniden doğrulama veya silme sırasında oluşabilecek hatalar
      if (e.code == 'wrong-password') {
        errorMessage = 'Girdiğiniz şifre yanlış.';
      } else if (e.code == 'requires-recent-login') {
        errorMessage =
            'Bu işlem hassas olduğu için yakın zamanda tekrar giriş yapmanız gerekiyor.';
      } else {
        errorMessage = 'Bir Firebase hatası oluştu: ${e.message}';
      }
      state = AsyncError(e, st);
    } catch (e, st) {
      errorMessage = 'Beklenmedik bir hata oluştu: $e';
      state = AsyncError(e, st);
    }

    return errorMessage; // Eğer bir hata oluştuysa, hata mesajını döndür.
  }
}

final accountControllerProvider =
    StateNotifierProvider.autoDispose<AccountController, AsyncValue<void>>(
        (ref) {
  return AccountController(ref);
});
