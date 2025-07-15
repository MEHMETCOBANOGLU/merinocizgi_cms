// lib/features/auth/utils/auth_methods.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWeb kontrolü için

// Bu metot artık sadece Google ile giriş yapıp UserCredential döndürmeye odaklanacak.
// Firestore'a yazma işini AuthController yapacak.
Future<UserCredential> signInWithGoogleMethod() async {
  // --- ANA DEĞİŞİKLİK BURADA ---

  // 1. GoogleSignIn nesnesini, web için clientId belirterek oluştur.
  // Bu, index.html'deki meta etiketine olan ihtiyacı ortadan kaldırır.
  final GoogleSignIn googleSignIn = GoogleSignIn(
    // kIsWeb kontrolü, bu clientId'nin sadece web platformunda kullanılmasını sağlar.
    clientId: kIsWeb
        ? "483380386928-8dnbtnanurmlk16dt4mh3psb0ibod1bn.apps.googleusercontent.com" // SENİN WEB CLIENT ID'N
        : null,
  );

  // 2. Bu yeni 'googleSignIn' nesnesi üzerinden giriş işlemini başlat.
  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  // --- DEĞİŞİKLİK SONU ---

  if (googleUser == null) {
    // Kullanıcı pencereyi kapattı veya işlemi iptal etti.
    throw FirebaseAuthException(
        code: 'user-cancelled', message: 'Giriş işlemi iptal edildi.');
  }

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

Future<UserCredential> signUpWithEmail({
  required String email,
  required String password,
}) async {
  return FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}

Future<UserCredential> signInWithEmail({
  required String email,
  required String password,
}) async {
  return FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}

Future<UserCredential> signInWithFacebookMethod() async {
  final LoginResult result = await FacebookAuth.instance.login();
  if (result.status == LoginStatus.success) {
    final OAuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } else if (result.status == LoginStatus.cancelled) {
    throw FirebaseAuthException(
        code: 'user-cancelled', message: 'Facebook girişi iptal edildi.');
  } else {
    throw FirebaseAuthException(
        code: 'facebook-login-failed', message: result.message);
  }
}
