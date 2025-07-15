import 'dart:html' as html;
import 'dart:math'; // min fonksiyonu için gerekli

void updateSeoTags({required String title, required String description}) {
  // 1. Sayfa başlığını güncelle
  html.document.title = title;

  // 2. Açıklama metnini güvenli bir şekilde kısalt
  // Metnin uzunluğu ile 155 arasında daha küçük olanı seçerek
  // metnin uzunluğunu aşmayı engelliyoruz.
  final safeLength = min(description.length, 155);
  final safeDescription = description.substring(0, safeLength);

  // 3. Mevcut description meta etiketini bul ve güncelle
  var element = html.document.querySelector('meta[name="description"]');
  if (element != null) {
    element.setAttribute('content', safeDescription);
  } else {
    // Eğer etiket yoksa, yeni bir tane oluştur ve ekle.
    element = html.MetaElement()
      ..name = 'description'
      ..content = safeDescription;
    html.document.head!.append(element);
  }

  // --- AYNI GÜVENLİ MANTIĞI OG:DESCRIPTION İÇİN DE UYGULAYALIM ---
  var ogElement =
      html.document.querySelector('meta[property="og:description"]');
  if (ogElement != null) {
    ogElement.setAttribute('content', safeDescription);
  } else {
    ogElement = html.MetaElement()
      ..setAttribute('property', 'og:description')
      ..content = safeDescription;
    html.document.head!.append(ogElement);
  }
}
