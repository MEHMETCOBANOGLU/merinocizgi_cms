import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/core/utils/responsive.dart';
import 'package:merinocizgi/core/utils/seo_utils.dart';
import 'package:merinocizgi/features/account/controller/account_controller.dart';
import 'package:merinocizgi/features/account/widget/series_chapters.dart';

class Myaccountpages extends ConsumerStatefulWidget {
  const Myaccountpages({super.key});

  @override
  ConsumerState<Myaccountpages> createState() => _MyaccountpagesState();
}

class _MyaccountpagesState extends ConsumerState<Myaccountpages> {
  // --- STATE DEĞİŞKENLERİ ---
  bool _isEditing = false;
  final _fullNameController = TextEditingController();
  final _mahlasController = TextEditingController();
  Uint8List? _newProfileImageBytes; // Seçilen yeni resmin verisi

  @override
  void dispose() {
    // Controller'ları temizlemeyi unutmuyoruz.
    _fullNameController.dispose();
    _mahlasController.dispose();
    super.dispose();
  }

  // --- FONKSİYONLAR ---

  // Görsel seçici fonksiyonu
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _newProfileImageBytes = result.files.single.bytes;
      });
    }
  }

  // Kaydetme işlemi
  Future<void> _saveProfile() async {
    // Butona basıldığında UI'ın hemen tepki vermesi için loading state'ini burada yönetebiliriz.
    // Ancak daha iyisi, controller'ın state'ini dinlemektir. Aşağıda butonda bunu yapacağız.

    // Controller'dan updateProfile metodunu çağır.
    // .notifier ile StateNotifier'ın kendisine erişiriz.
    final success =
        await ref.read(accountControllerProvider.notifier).updateProfile(
              fullName: _fullNameController.text.trim(),
              mahlas: _mahlasController.text.trim(),
              newProfileImage: _newProfileImageBytes,
            );

    // `mounted` kontrolü, widget ağaçtan kaldırıldıysa (örneğin kullanıcı sayfadan ayrıldıysa)
    // hata almayı önler.
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil başarıyla güncellendi!')),
      );
      // Başarılı olursa, görüntüleme moduna geri dön.
      setState(() {
        _isEditing = false;
        _newProfileImageBytes = null;
      });
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profil güncellenirken bir hata oluştu.'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = context.isTabletB;

    // --- SEO GÜNCELLEMESİ ---
    // Bu widget her çizildiğinde başlık ve açıklama güncellenir.
    updateSeoTags(
      title: "MerinoÇizgi - Profil",
      description:
          'MerinoÇizgi Profil Sayfası', // Açıklamayı ilk 155 karakterle sınırla
    );

    // Profil panelini oluşturan fonksiyon
    Widget buildProfilePanel() {
      final userProfile = ref.watch(userProfileProvider);
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.bg,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: userProfile.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text("Profil bilgileri yüklenemedi."));
            }
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isEditing
                  ? _buildEditProfileView(user)
                  : _buildViewProfileView(user),
            );
          },
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (isWideScreen) {
      // --- GENİŞ EKRAN LAYOUT'U (Row) ---
      // Bu kısım zaten doğru çalışıyor, değişiklik yok.
      return Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: SingleChildScrollView(child: buildProfilePanel()),
          ),
          const Expanded(child: AuthorSeriesDashboard()),
        ],
      );
    } else {
      // --- DAR EKRAN LAYOUT'U (CustomScrollView) ---
      // Bu yapı, farklı widget'ları tek bir kaydırılabilir listede birleştirir.
      return CustomScrollView(
        slivers: [
          // 1. Parça: Profil Paneli
          // SliverToBoxAdapter, buildProfilePanel'in döndürdüğü Container gibi
          // normal bir widget'ı, kaydırılabilir listenin bir elemanı yapar.
          SliverToBoxAdapter(
            child: buildProfilePanel(),
          ),

          // 2. Parça: Yazarın Serileri
          // SliverFillRemaining, kalan tüm alanı dolduran bir sliver'dır.
          // İçindeki AuthorSeriesDashboard'un (ve onun ListView'ının)
          // bu alana yayılmasını sağlar ve layout hatalarını önler.
          const SliverFillRemaining(
            hasScrollBody: true, // İçeriğin kaydırılabilir olduğunu belirtir
            child: AuthorSeriesDashboard(),
          ),
        ],
      );
    }
  }

  // --- YARDIMCI WIDGET OLUŞTURMA FONKSİYONLARI ---
  // Bu fonksiyonlar artık state'in build metodunun içinde ve private.

  /// Görüntüleme modunu oluşturan yardımcı widget.
  Widget _buildViewProfileView(Map<String, dynamic> user) {
    return ListView(
      key: const ValueKey('viewProfile'),
      shrinkWrap: true, // Üstündeki Column'un boyutunu almasını sağlar
      physics: const NeverScrollableScrollPhysics(), // Kendi başına kaymasın
      padding: EdgeInsets.zero,
      children: [
        // const SizedBox(height: 20),
        CircleAvatar(
          radius: 100,
          backgroundColor: AppColors.bg,
          backgroundImage: user['profileImageUrl'] != null
              ? NetworkImage(user['profileImageUrl'])
              : null,
          child: user['profileImageUrl'] == null
              ? Icon(Icons.account_circle, size: 200, color: AppColors.primary)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user['fullName'] ?? 'İsim Belirtilmemiş',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user['mahlas'] != null && user['mahlas'].isNotEmpty
              ? user['mahlas']
              : 'Mahlas Belirtilmemiş',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.grey.shade600),
        ),
        const Divider(height: 50, thickness: 1.5, color: Colors.black12),
        _buildInfoRow(Icons.email_outlined, user['email']),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Profili Düzenle'),
              onPressed: () {
                _fullNameController.text = user['fullName'] ?? '';
                _mahlasController.text = user['mahlas'] ?? '';
                setState(() => _isEditing = true);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: InkWell(
            onTap: _showDeleteConfirmationDialog,
            child: const Text('Hesabımı Kapat',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  // --- GÜNCELLENMİŞ DİYALOG GÖSTERME FONKSİYONU ---
  Future<void> _showDeleteConfirmationDialog() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Diyalog, kullanıcıdan şifre girmesini isteyecek.
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Hesabı Kalıcı Olarak Sil',
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(color: Colors.black),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Bu işlem geri alınamaz. Devam etmek için lütfen şifrenizi girin'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Şifre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi girin.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            // TextButton(
            //   onPressed: () =>
            //       Navigator.of(dialogContext).pop(false), // Onaylamadı
            //   child: const Text('Vazgeç'),
            // ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Şifre girildiyse, diyaloğu kapat ve 'true' değerini döndür.
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Hesabımı Sil'),
            ),
          ],
        );
      },
    );

    // Eğer kullanıcı "Hesabımı Sil" butonuna basmadıysa (veya Vazgeç dediyse) devam etme.
    if (confirmed != true) return;

    // --- CONTROLLER'I ÇAĞIRMA KISMI ---
    // Diyalogdan alınan şifre ile controller'daki silme metodunu çağır.
    final errorMessage = await ref
        .read(accountControllerProvider.notifier)
        .deleteAccount(passwordController.text);

    // İşlem sonrası UI'da geri bildirim göster.
    if (!mounted) return;

    if (errorMessage == null) {
      // Başarılı. Kullanıcı zaten silindiği için AuthStateProvider bunu algılayıp
      // otomatik olarak giriş ekranına yönlendirecektir.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hesabınız başarıyla silindi.'),
          backgroundColor: Colors.green,
        ),
      );
      // Gerekirse context.go('/') ile ana sayfaya yönlendirme yapılabilir.
    } else {
      // Hata oluştu.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Düzenleme modunu oluşturan yardımcı widget.
  Widget _buildEditProfileView(Map<String, dynamic> user) {
    // Provider'ın durumunu dinle (watch).
    final profileUpdateState = ref.watch(accountControllerProvider);
    final isSaving = profileUpdateState is AsyncLoading;

    return SingleChildScrollView(
      key: const ValueKey('editProfile'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 24),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 90,
                  backgroundImage: _newProfileImageBytes != null
                      ? MemoryImage(_newProfileImageBytes!) as ImageProvider
                      : NetworkImage(user['profileImageUrl'] ??
                          'https://via.placeholder.com/300'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton.filled(
                    onPressed: isSaving
                        ? null
                        : _pickImage, // Kaydederken resim seçmeyi engelle
                    icon: const Icon(Icons.edit),
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("İsim Soyisim",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _fullNameController,
            enabled: !isSaving, // Kaydederken düzenlemeyi engelle
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Adınız ve Soyadınız",
            ),
          ),
          const SizedBox(height: 16),
          const Text("Mahlas (Yazar Adı)",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _mahlasController,
            enabled: !isSaving, // Kaydederken düzenlemeyi engelle
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Okuyucularınızın göreceği isim",
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  // Eğer kaydetme işlemi devam ediyorsa onPressed'i null yap (butonu pasif hale getir).
                  onPressed: isSaving ? null : _saveProfile,

                  // Buton içeriğini duruma göre değiştir.
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Kaydet',
                          style: AppTextStyles.text,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          // Kaydederken iptal etmeyi engelle
                          setState(() {
                            _isEditing = false;
                            _newProfileImageBytes = null;
                          });
                        },
                  child: Text(
                    'İptal',
                    style: AppTextStyles.text,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // Tekrar eden UI'lar için küçük bir yardımcı metot
  Widget _buildInfoRow(IconData icon, String? text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Text(
          text ?? '',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
