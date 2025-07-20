// rules_version = '2';
// service cloud.firestore {
//   match /databases/{database}/documents {

//     // MEVCUT KURALLARINIZ BURADA KALABİLİR
//     match /users/{userId}/{document=**} {
//       allow read, write: if request.auth.uid == userId;
//     }

//     // --- YENİ EKLENECEK KURAL ---
//     // 'comics' koleksiyon grubundaki tüm dokümanlar için geçerli olacak kural.
//     match /{path=**}/comics/{comicId} {
//       // Bir kullanıcının okuma yapmasına SADECE ve SADECE
//       // okumaya çalıştığı 'comic' dokümanının içindeki 'userId' alanı,
//       // isteği yapan kullanıcının kendi ID'si ise izin ver.
//       allow read: if request.auth.uid == resource.data.userId;
//     }
//   }
// }
