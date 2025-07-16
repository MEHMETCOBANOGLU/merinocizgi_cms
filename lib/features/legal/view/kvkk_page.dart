import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/typography.dart';

class KvkkPage extends StatelessWidget {
  const KvkkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text("KVKK Aydınlatma Metni",
                style: AppTextStyles.oswaldTitle.copyWith(color: Colors.black)),
          ),
          const Divider(height: 32),
          _buildParagraph(
              "Bu aydınlatma metni, 6698 sayılı Kişisel Verilerin Korunması Kanunu ('KVKK') uyarınca, Veri Sorumlusu sıfatıyla MerinoÇizgi tarafından, kişisel verilerinizin işlenmesine ilişkin olarak sizleri bilgilendirmek amacıyla hazırlanmıştır."),
          _buildSectionTitle("1. İşlenen Kişisel Veriler"),
          _buildParagraph(
              "Platformumuza üye olmanız ve hizmetlerimizi kullanmanız durumunda aşağıdaki kişisel verileriniz işlenmektedir:\n"
              "- Kimlik Bilgileri: Ad, soyad, mahlas.\n"
              "- İletişim Bilgileri: E-posta adresi.\n"
              "- İşlem Güvenliği Bilgileri: IP adresi, şifre (şifrelenmiş olarak), giriş/çıkış kayıtları.\n"
              "- Yazar Bilgileri: Yayınlanan seriler, bölümler ve ilgili meta veriler."),
          _buildSectionTitle("2. Kişisel Verilerin İşlenme Amaçları"),
          _buildParagraph(
              "Kişisel verileriniz; üyelik işlemlerinin gerçekleştirilmesi, hizmetlerimizin sunulması, platform güvenliğinin sağlanması, sizinle iletişim kurulması, yasal yükümlülüklerin yerine getirilmesi ve hizmet kalitemizin artırılması amaçlarıyla işlenmektedir."),
          _buildSectionTitle("3. Kişisel Verilerin Aktarılması"),
          _buildParagraph(
              "Kişisel verileriniz, yasal zorunluluklar ve rızanız dışında üçüncü kişilerle kesinlikle paylaşılmaz. Verileriniz, yurtiçinde bulunan güvenli sunucularda (Google Firebase) saklanmaktadır."),
          _buildSectionTitle("4. İlgili Kişinin Hakları"),
          _buildParagraph(
              "KVKK'nın 11. maddesi uyarınca, veri sahibi olarak; kişisel verilerinizin işlenip işlenmediğini öğrenme, işlenmişse buna ilişkin bilgi talep etme, işlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme, verilerinizin düzeltilmesini, silinmesini veya yok edilmesini isteme haklarına sahipsiniz. Bu haklarınızı kullanmak için [info@merinocizgi.com.tr] adresinden bizimle iletişime geçebilirsiniz."),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(title,
          style: AppTextStyles.oswaldSubtitle.copyWith(color: Colors.black)),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(text,
        style: AppTextStyles.oswaldText.copyWith(color: Colors.black87));
  }
}
