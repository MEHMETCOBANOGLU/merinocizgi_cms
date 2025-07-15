// // lib/features/auth/utils/auth_methods.dart

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// // Bu metot artık sadece Google ile giriş yapıp UserCredential döndürmeye odaklanacak.
// // Firestore'a yazma işini AuthController yapacak.
// Future<UserCredential> signInWithGoogleMethod() async {
//   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//   if (googleUser == null) {
//     // Kullanıcı pencereyi kapattı veya işlemi iptal etti.
//     throw FirebaseAuthException(
//         code: 'user-cancelled', message: 'Giriş işlemi iptal edildi.');
//   }

//   final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//   final AuthCredential credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth.accessToken,
//     idToken: googleAuth.idToken,
//   );

//   return await FirebaseAuth.instance.signInWithCredential(credential);
// }

// Future<UserCredential> signUpWithEmail({
//   required String email,
//   required String password,
// }) async {
//   return FirebaseAuth.instance.createUserWithEmailAndPassword(
//     email: email,
//     password: password,
//   );
// }

// Future<UserCredential> signInWithEmail({
//   required String email,
//   required String password,
// }) async {
//   return FirebaseAuth.instance.signInWithEmailAndPassword(
//     email: email,
//     password: password,
//   );
// }
