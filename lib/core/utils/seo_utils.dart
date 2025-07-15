// lib/core/utils/seo_utils.dart

// Bu bir "koşullu export" dosyasıdır.
// Platforma göre (web veya mobil) doğru implementasyonu dışa aktarır.

export 'seo_utils_non_web.dart' // Varsayılan olarak mobil versiyonunu kullan
    if (dart.library.html) 'seo_utils_web.dart'; // EĞER platformda 'dart:html' kütüphanesi varsa, web versiyonunu kullan.
