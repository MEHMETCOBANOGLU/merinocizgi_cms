// lib/core/utils/responsive.dart

import 'package:flutter/widgets.dart';
import 'package:merinocizgi/core/theme/breakpoints.dart';

/// BuildContext üzerinde “ekran boyutu” kontrolleri yapabilmek
/// için eklediğimiz extension metodları.
extension Responsive on BuildContext {
  /// true dönerse ekran genişliği en az tablet eşik değeri (600px) demektir.
  bool get isTablet => MediaQuery.of(this).size.width >= AppBreakpoints.tablet;
  bool get isTabletB =>
      MediaQuery.of(this).size.width >= AppBreakpoints.tabletB;
  // bool get isPhone => MediaQuery.of(this).size.width >= AppBreakpoints.phone;

  /// true dönerse ekran genişliği en az masaüstü eşik değeri (1024px) demektir.
  bool get isDesktop =>
      MediaQuery.of(this).size.width >= AppBreakpoints.desktop;
}


// BuildContext’e (yani her context’e) ek metodlar (extension) tanımlıyoruz;
// bu sayede context.isTablet veya context.isDesktop diyerek kontrol yapabiliriz.