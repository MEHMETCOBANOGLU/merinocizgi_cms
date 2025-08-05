<!-- '#', en büyük başlık (h1) oluşturur. 'align="center"' ile ortalanır. -->
<h1 align="center">MerinoÇizgi - Dijital Çizgi Roman & Kitap Platformu</h1>

<!-- 'p' etiketi bir paragraf oluşturur. 'align="center"' ile ortalanır. -->
<p align="center">
  <!-- 'img', bir resim ekler. 'width' ile boyutu ayarlanır. -->
  <img src="https://merinocizgi.com.tr/android-chrome-192x192.png" width="200" alt="MerinoÇizgi Logo">
</p>

<p align="center">
  <!-- 'strong', metni kalın yapar. -->
  <strong>Yetenekli sanatçıların ve yazarların eserlerini okuyucularla buluşturduğu, yeni nesil bir dijital yayıncılık platformu.</strong>
  <br> <!-- '<br>', bir satır boşluk bırakır. -->
  <!-- 'a', bir link oluşturur. 'href' linkin adresidir. -->
  <a href="https://merinocizgi.com.tr/"><strong>Canlı Siteyi Ziyaret Et »</strong></a>
</p>

<!-- Rozetlerin olduğu bölüm. Her 'img' bir rozettir. -->
<p align="center">
    <img src="https://img.shields.io/badge/Flutter-Web-blue?style=for-the-badge&logo=flutter" alt="Flutter Web">
    <img src="https://img.shields.io/badge/Flutter-Mobile-blue?style=for-the-badge&logo=flutter" alt="Flutter Mobile">
    <img src="https://img.shields.io/badge/Firebase-Backend-orange?style=for-the-badge&logo=firebase" alt="Firebase">
    <img src="https://img.shields.io/badge/State%20Management-Riverpod-purple?style=for-the-badge&logo=c" alt="Riverpod">
</p>

<!-- '##', ikinci seviye başlık (h2) oluşturur. Emoji eklemek dikkat çeker. -->

## 📖 Proje Hakkında

MerinoÇizgi, bağımsız çizgi roman sanatçıları ve yazarlar için tasarlanmış, hem bir **İçerik Yönetim Sistemi (CMS)** hem de okuyucular için bir **mobil uygulama** sunan tam teşekküllü (full-stack) bir platformdur. Sanatçıların kendi serilerini ve bölümlerini kolayca yükleyip yönetebildiği, okuyucuların ise bu özgün içerikleri keşfedip mobil uygulama üzerinden okuyabildiği, baştan sona tasarlanmış ve kodlanmış bir uygulamadır. Proje, modern bir kullanıcı arayüzü ile güçlü bir backend altyapısını bir araya getirmektedir.

<!-- '**' veya '__', metni kalın (bold) yapar. -->

**Not:** Platform, Wattpad benzeri bir yapıda, yazarların kendi kitaplarını bölüm bölüm yayınlamasına da olanak tanıyarak kapsamını genişletmektedir.

## ✨ Öne Çıkan Özellikler

<!-- '-', sıralı olmayan bir liste (unordered list) oluşturur. -->

- **Çok Platformlu (Cross-Platform):** Tek bir Dart kod tabanı ile hem **Flutter Web** tabanlı bir CMS hem de **Android/iOS** için bir mobil uygulama.
- **Rol Tabanlı Yetkilendirme:** Firebase Custom Claims kullanılarak oluşturulmuş **Admin** ve **Yazar** rolleri. Adminler içerikleri onaylar, yazarlar içerik üretir.
- **İçerik Yönetim Sistemi (CMS):**
  - Sanatçılar için çizgi roman serileri ve bölümleri oluşturma.
  - Yazarlar için kitaplar ve metin tabanlı bölümler oluşturma.
  - Kapak resmi, açıklama, kategori, etiketler gibi zengin meta veri yönetimi.
- **İçerik Onay Akışı:** Yazarlar tarafından gönderilen tüm içerikler, bir admin tarafından incelenip onaylanana kadar (`pending` durumunda) okuyuculara gizli kalır.
- **Dinamik Mobil Ana Sayfa:** "Haftanın Serisi", "En Popülerler", "Yeni Hikayeler" ve "Kategoriye Göre Filtreleme" gibi veri odaklı, dinamik bölümler.
- **Sosyal Etkileşim:**
  - Yazar odaklı **takip/takipçi** sistemi.
  - Seri ve kitaplar için **puanlama (rating)** sistemi.
  - Kullanıcıların kendi **özel okuma listelerini (kütüphanelerini)** oluşturabilmesi.
- **SEO Optimizasyonu:** Flutter Web için dinamik meta etiketleri, `robots.txt` ve `sitemap.xml` ile arama motoru dostu yapı.

## 🛠️ Kullanılan Teknolojiler ve Mimarisi

Bu proje, ölçeklenebilir ve sürdürülebilir bir yapı için **Clean Architecture** prensiplerinden ilham alınarak katmanlı bir mimariyle geliştirilmiştir.

- **Frontend (UI):**

  - **Framework:** `Flutter 3.x`
  - **State Management:** `Riverpod` (StateNotifier, FutureProvider, StreamProvider.family)
  - **Routing:** `GoRouter` (Platforma özel (Web/Mobil) ve rol bazlı yönlendirme)
  - **UI:** `Material Design 3`, Responsive Layout (`Flex`, `LayoutBuilder`, `CustomScrollView`)

- **Backend (BaaS - Backend as a Service):**

  - **Veritabanı:** `Cloud Firestore` (Güvenlik Kuralları ile korunmuş NoSQL veritabanı)
  - **Kimlik Doğrulama:** `Firebase Authentication` (E-posta/Şifre, Google, Facebook ve rol yönetimi için Custom Claims)
  - **Dosya Depolama:** `Firebase Storage` (Kapak resimleri, çizgi roman sayfaları vb. için güvenli dosya depolama)
  - **Sunucu Tarafı Mantığı (Serverless):** `Cloud Functions for Firebase` (Node.js)
    - Kullanıcı takip ettiğinde sayaçları ve koleksiyonları otomatik güncelleme.
    - İçerik puanlandığında ortalama rating'i yeniden hesaplama.
    - İçerik görüntülendiğinde `viewCount` sayacını artırma.
    - Adminler için "inceleme görevleri" (`reviews`) koleksiyonunu otomatik oluşturma.

- **Veri Modelleme:**
  - **`freezed` & `json_serializable`:** Değişmez (immutable) ve tip güvenli (type-safe) data sınıfları oluşturmak ve Firestore ile kolay entegrasyon için.

## 🚀 Kurulum ve Çalıştırma

<!-- '1.', sıralı bir liste (ordered list) oluşturur. -->

1.  **Firebase Projesi Kurulumu:**

    - Bir Firebase projesi oluşturun.
    - Authentication, Firestore, Storage ve Functions servislerini etkinleştirin.
    - Projenizi FlutterFire CLI ile yapılandırın: `flutterfire configure`

2.  **Bağımlılıkları Yükleme:**
    <!-- Üç tane ters tırnak (```), bir kod bloğu oluşturur. 'bash' dili belirtir. -->

    ```bash
    flutter pub get
    ```

3.  **Kod Üretimini Çalıştırma:**

    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Cloud Functions'ı Deploy Etme:**

    ```bash
    cd functions
    npm install
    firebase deploy --only functions
    ```

5.  **Uygulamayı Çalıştırma:**
    - **Web (CMS):** `flutter run -d chrome`
    - **Mobil (Okuyucu):** `flutter run` (bağlı bir cihaz veya emülatör ile)

## 👤 Geliştirici

**Mehmet Çobanoğlu**

- GitHub: [@MEHMETCOBANOGLU](https://github.com/MEHMETCOBANOGLU)
- LinkedIn: [linkedin.com/in/mehmet-çobanoğlu](https://www.linkedin.com/in/mehmet-çobanoğlu/)
- E-posta: `mehmett_ceng@hotmail.com`

## License

This project is **not open source**. All rights reserved © 2025 MEHMETCOBANOGLU.  
Unauthorized use, copying, or distribution is strictly prohibited.
