//Kullanım Koşulları
import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/typography.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text("Kullanım Koşulları",
                style: AppTextStyles.oswaldTitle.copyWith(color: Colors.black)),
          ),
          const SizedBox(height: 16),
          const Text("Son Güncelleme: 13.07.2025"),
          const Divider(height: 32),
          _buildSectionTitle("1. Taraflar ve Tanımlar"),
          _buildParagraph(
              "Bu Kullanım Koşulları, MerinoÇizgi ('Platform') ile Platform'a üye olan veya ziyaret eden kullanıcı ('Kullanıcı') ve içerik üreten sanatçılar ('Yazar') arasındaki ilişkiyi düzenler. Platform'u kullanarak bu koşulları kabul etmiş sayılırsınız."),
          _buildSectionTitle("2. Hizmetlerin Tanımı"),
          _buildParagraph(
              "MerinoÇizgi, Yazarların kendi özgün çizgi roman, manga ve benzeri görsel eserlerini ('İçerik') yayınlayabildiği ve Kullanıcıların bu içeriklere erişebildiği bir dijital platformdur."),
          _buildSectionTitle("3. Yazar Sorumlulukları ve İçerik Mülkiyeti"),
          _buildParagraph(
              "a) Yazar, Platform'a yüklediği tüm İçeriklerin orijinal sahibi olduğunu, üçüncü şahısların telif haklarını, ticari markalarını veya diğer mülkiyet haklarını ihlal etmediğini beyan ve taahhüt eder.\n"
              "b) Yazar, İçeriğin mülkiyetini elinde tutar. Ancak, İçeriği Platform'a yükleyerek, MerinoÇizgi'ye bu İçeriği Platform üzerinde sergilemek, tanıtmak ve dağıtmak için dünya çapında, münhasır olmayan, telifsiz bir lisans vermiş olur.\n"
              "c) Yasa dışı, nefret söylemi içeren, pornografik, şiddeti teşvik eden veya rahatsız edici içeriklerin yüklenmesi kesinlikle yasaktır. Bu tür içerikler haber verilmeksizin kaldırılabilir ve Yazar'ın hesabı askıya alınabilir."),
          _buildSectionTitle("4. Kullanıcı Sorumlulukları"),
          _buildParagraph(
              "Kullanıcılar, Platform'daki içeriklere saygılı bir şekilde yorum yapmayı, diğer kullanıcılara ve yazarlara karşı taciz edici veya aşağılayıcı bir dil kullanmamayı kabul eder. Platform'daki içeriklerin izinsiz kopyalanması, dağıtılması veya ticari amaçlarla kullanılması yasaktır."),
          _buildSectionTitle("5. Sorumluluğun Sınırlandırılması"),
          _buildParagraph(
              "MerinoÇizgi, Yazarlar tarafından yüklenen İçeriklerin doğruluğundan, yasallığından veya kalitesinden sorumlu tutulamaz. Platform, 'olduğu gibi' sunulmaktadır ve kesintisiz veya hatasız olacağı garanti edilmez."),
          _buildSectionTitle("6. Koşulların Değiştirilmesi"),
          _buildParagraph(
              "MerinoÇizgi, bu Kullanım Koşullarını dilediği zaman değiştirme hakkını saklı tutar. Değişiklikler Platform üzerinde yayınlandığı andan itibaren geçerli olur."),
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
