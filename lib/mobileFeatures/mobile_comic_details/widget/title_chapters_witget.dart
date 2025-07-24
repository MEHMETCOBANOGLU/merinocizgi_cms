// lib/mobileFeatures/mobile_comic_details/widget/title_chapters_widget.dart

import 'package:flutter/material.dart';

// Mevcut TitleChaptersWidget'ınız
class TitleChaptersWidget extends StatelessWidget {
  const TitleChaptersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bu widget'ın içeriği, delegate içinde kullanılacak.
    return Container(
      // Arka plan rengi, yapıştığında içeriğin arkasında kalmasın diye önemli.
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        "Bölümler",
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// --- YENİ EKLENEN DELEGATE SINIFI ---
// Bu sınıf, TitleChaptersWidget'ın bir Sliver olarak nasıl davranacağını tanımlar.
class SliverChapterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TitleChaptersWidget child;

  SliverChapterHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // shrinkOffset, başlığın ne kadar küçüldüğünü belirtir (bizim durumumuzda sabit).
    // overlapsContent, başlığın ana içeriğin üzerine gelip gelmediğini belirtir.
    return child;
  }

  // Başlığın maksimum (tamamen açık) yüksekliği.
  // TitleChaptersWidget'ın padding'i ve metin yüksekliğine göre ayarla.
  @override
  double get maxExtent => 56.0;

  // Başlığın minimum (yapışık) yüksekliği.
  // Pinned olduğunda bu yükseklikte kalır.
  @override
  double get minExtent => 56.0;

  // Başlığın içeriği değiştiğinde yeniden oluşturulup oluşturulmayacağı.
  // Bizimki statik olduğu için false dönebiliriz.
  @override
  bool shouldRebuild(SliverChapterHeaderDelegate oldDelegate) {
    return false;
  }
}
