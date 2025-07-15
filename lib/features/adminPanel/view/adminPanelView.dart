// lib/admin/make_admin.dart (örnek bir dosya yolu)

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Bir kullanıcıyı admin yapmak için kullanacağımız fonksiyon
Future<void> makeUserAdmin(BuildContext context, String email) async {
  final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  // Fonksiyonumuzun referansını alıyoruz. 'addAdminRole' ismi, index.js'deki isimle aynı olmalı.
  final HttpsCallable callable = functions.httpsCallable('addAdminRole');

  // Yükleniyor göstergesi için bir diyalog gösterelim
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("İşleniyor..."),
            ],
          ),
        ),
      );
    },
  );

  try {
    // Fonksiyonu çağır ve 'email' parametresini gönder
    // Parametreleri doğrudan Map olarak gönderiyoruz.
    // cloud_functions paketi bunu doğru şekilde saracaktır.
    final result = await callable.call<Map<String, dynamic>>({
      'email': email,
    });

    Navigator.of(context).pop(); // Yükleniyor diyaloğunu kapat

    // Başarılı olursa, Cloud Function'dan dönen mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.data['message'] ?? 'İşlem başarılı!'),
        backgroundColor: Colors.green,
      ),
    );
  } on FirebaseFunctionsException catch (e) {
    Navigator.of(context).pop(); // Yükleniyor diyaloğunu kapat

    // Hata olursa, Cloud Function'dan dönen hata mesajını ve kodunu göster
    // Bu, sorunu anlamamıza yardımcı olur (örn: 'permission-denied', 'internal', 'invalid-argument')
    print('Cloud Functions Hatası Kodu: ${e.code}');
    print('Cloud Functions Hatası Mesajı: ${e.message}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('HATA: ${e.message ?? "Bilinmeyen bir Firebase hatası."}'),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    Navigator.of(context).pop(); // Yükleniyor diyaloğunu kapat

    // Diğer beklenmedik hatalar için
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Beklenmedik bir hata oluştu: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Örnek kullanım için olan Widget'ta bir değişiklik yapmaya gerek yok.
// AdminPanelPage kodunuz aynı kalabilir.
class AdminPanelPage extends StatefulWidget {
  // StatelessWidget'tan StatefulWidget'a değiştir
  const AdminPanelPage({super.key});

  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  // State sınıfını ekle
  final TextEditingController _emailController = TextEditingController();
  bool _isTokenReady = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  // Token'ın hazır olduğundan emin olmak için bir kontrol fonksiyonu
  Future<void> _checkToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // ID token'ı manuel olarak yenilemeye zorla.
        // Bu, token'ın isteğe ekleneceğinden emin olmamızı sağlar.
        await user.getIdToken(true);
        setState(() {
          _isTokenReady = true;
          _userId = user.uid;
        });
        print("✅ Token yenilendi ve hazır. UID: ${user.uid}");
      } catch (e) {
        print("❌ Token yenileme hatası: $e");
        setState(() {
          _isTokenReady = false;
        });
      }
    } else {
      print("🤔 Kullanıcı bulunamadı.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              "Admin Paneli (Kullanıcı: ${_userId ?? 'Giriş yapılmamış'})")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: "Admin yapılacak kullanıcının e-postası",
                  hintText: "ornek@mail.com"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Butonu sadece token hazır olduğunda aktif et
            ElevatedButton(
              onPressed: _isTokenReady
                  ? () {
                      // Butonun onPressed'ini kontrol et
                      if (_emailController.text.trim().isNotEmpty) {
                        if (RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(_emailController.text.trim())) {
                          makeUserAdmin(context, _emailController.text.trim());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Lütfen geçerli bir e-posta adresi girin.')));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('E-posta alanı boş bırakılamaz.')));
                      }
                    }
                  : null, // Token hazır değilse buton pasif olsun

              child: _isTokenReady
                  ? const Text("Admin Yap")
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Token bekleniyor..."),
                        SizedBox(width: 8),
                        SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            )),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
