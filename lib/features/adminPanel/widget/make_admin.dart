import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/typography.dart';

class MakeAdminPopUp extends StatefulWidget {
  const MakeAdminPopUp({Key? key}) : super(key: key);

  @override
  State<MakeAdminPopUp> createState() => _MakeAdminPopUpState();
}

class _MakeAdminPopUpState extends State<MakeAdminPopUp> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _makeUserAdmin() async {
    // Form geçerli değilse işlemi başlatma.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    final callable = functions.httpsCallable('addAdminRole');
    String? errorMessage;
    String? successMessage;

    try {
      final result =
          await callable.call<Map<String, dynamic>>({'email': email});
      successMessage = result.data['message'] ?? 'İşlem başarılı!';
    } on FirebaseFunctionsException catch (e) {
      errorMessage = e.message ?? "Bilinmeyen bir Firebase hatası.";
    } catch (e) {
      errorMessage = "Beklenmedik bir hata oluştu: $e";
    }

    // Bu widget hala ağaçtaysa (kullanıcı diyaloğu kapatmadıysa) devam et.
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // İşlem bittikten sonra diyaloğu kapat.
    Navigator.of(context).pop();

    // Ana ekranda sonucu göster.
    if (successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      );
    }
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('HATA: $errorMessage'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    return AlertDialog(
      // todo ı want to change width and height size

      title: Center(
          child: Text("Yeni Admin Ata",
              style: AppTextStyles.title.copyWith(color: Colors.black))),
      content: SizedBox(
        width: screenW * 0.3,
        height: screenH * 0.12,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlan
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "E-posta",
                  hintText: "ornek@mail.com",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'E-posta alanı boş bırakılamaz.';
                  }
                  if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value)) {
                    return 'Lütfen geçerli bir e-posta adresi girin.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _isLoading ? null : _makeUserAdmin,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Admin Yap"),
        ),
      ],
    );
  }
}
