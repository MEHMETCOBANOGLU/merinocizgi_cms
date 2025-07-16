import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/typography.dart';

class CookiePolicyPage extends StatelessWidget {
  const CookiePolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text("Çerez Politikası",
                style: AppTextStyles.oswaldTitle.copyWith(color: Colors.black)),
          ),
          const Divider(height: 32),
          _buildParagraph(
              "MerinoÇizgi olarak, web sitemizin verimli çalışmasını sağlamak ve kullanıcı deneyimini iyileştirmek amacıyla çerezler kullanmaktayız."),
          _buildSectionTitle("1. Çerez Nedir?"),
          _buildParagraph(
              "Çerezler, bir web sitesini ziyaret ettiğinizde bilgisayarınıza veya mobil cihazınıza kaydedilen küçük metin dosyalarıdır."),
          _buildSectionTitle("2. Kullandığımız Çerez Türleri"),
          _buildParagraph(
              "a) Oturum Çerezleri (Zorunlu): Kullanıcı girişi gibi temel fonksiyonların çalışması için gereklidir. Tarayıcınızı kapattığınızda silinirler. (Örn: Firebase Authentication'ın kullandığı kimlik doğrulama token'ları).\n"
              "b) Performans ve Analiz Çerezleri (Opsiyonel): Sitemizin nasıl kullanıldığını anlamak, ziyaretçi sayısını ölçmek ve hizmetlerimizi iyileştirmek için Google Analytics gibi üçüncü parti servislerin çerezlerini kullanabiliriz. Bu çerezler, kimliğinizi doğrudan ifşa etmeyen anonim veriler toplar."),
          _buildSectionTitle("3. Çerezleri Nasıl Kontrol Edebilirsiniz?"),
          _buildParagraph(
              "Tarayıcı ayarlarınızı değiştirerek çerezleri kabul etmeyi veya reddetmeyi tercih edebilirsiniz. Ancak zorunlu çerezleri engellemeniz, platformumuzun bazı özelliklerinin düzgün çalışmamasına neden olabilir."),
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
