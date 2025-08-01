// lib/mobileFeatures/shared/providers/bottom_bar_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bu provider, uygulamanın hangi ana sekmesinde olduğumuzu global olarak tutar.
// ShellRoute'taki her sayfa bu provider'ı güncelleyerek BottomBar'ın senkronize kalmasını sağlar.
final selectedBottomBarIndexProvider = StateProvider<int>((ref) => 0);

// Başlangıçta null; ölçülünce set edilir.
final bottomBarHeightProvider = StateProvider<double?>((ref) => null);
