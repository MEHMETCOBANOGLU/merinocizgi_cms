// lib/features/home/view/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/utils/seo_utils.dart';
import 'package:merinocizgi/core/widgets/app_footer.dart';
import 'package:merinocizgi/features/auth/widgets/email_verification_banner.dart';
import 'package:merinocizgi/features/home/controller/home_controller.dart'; // YENİ IMPORT
import 'package:merinocizgi/features/home/widgets/about.dart';
import 'package:merinocizgi/features/home/widgets/Comics.dart';
import 'package:merinocizgi/features/home/widgets/PhoneFilmStrip.dart';
import 'package:merinocizgi/features/home/widgets/artist.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- SEO GÜNCELLEMESİ ---
    // Bu widget her çizildiğinde başlık ve açıklama güncellenir.
    updateSeoTags(
      title: "MerinoÇizgi - Anasayfa",
      description:
          'MerinoÇizgi Anasayfa', // Açıklamayı ilk 155 karakterle sınırla
    );
    // --- DEĞİŞİKLİK BURADA ---
    // ScrollController'ı provider'dan İZLE (watch).
    final scrollController = ref.watch(homeScrollControllerProvider);

    // Key'leri provider'dan alıp ilgili widget'lara ata.
    final merinoKey = ref.watch(merinoKeyProvider);
    final comicsKey = ref.watch(comicsKeyProvider);
    final artistsKey = ref.watch(artistsKeyProvider);

    // HomeController'a bu key'leri bildirmek için bir yol bulmamız lazım.
    // Şimdilik, HomeLayout'taki onNavTap'e doğrudan key gönderelim.
    // Bu, önceki yapıda zaten doğruydu.

    // Sadece sayfa içeriğini döndür.
    return SingleChildScrollView(
      // Controller'ı provider'dan alıp buraya bağlıyoruz.
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const EmailVerificationBanner(),
          About(key: merinoKey),
          PhoneFilmStrip(),
          ComicsSection(key: comicsKey),
          ArtistsSection(key: artistsKey),
          AppFooter(),
        ],
      ),
    );
  }
}
