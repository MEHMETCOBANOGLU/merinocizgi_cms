/// Uygulamanın farklı cihaz tiplerine (mobile, tablet, desktop) göre
/// düzen (layout) tercih etmek için kullandığımız sabitler.
class AppBreakpoints {
  /// “Tablet” düzenine geçiş yapmak için minimum ekran genişliği.
  /// Eğer ekran genişliği 750 piksel veya daha fazla ise, tablet düzenini kullan.
  static const double tablet = 800.0;
  static const double tabletB = 1200.0;
  // static const double phone = 550.0;

  /// “Desktop” düzenine geçiş yapmak için minimum ekran genişliği.
  /// Eğer ekran genişliği 1024 piksel veya daha fazla ise, masaüstü düzenini kullan.
  static const double desktop = 1024.0;
}
