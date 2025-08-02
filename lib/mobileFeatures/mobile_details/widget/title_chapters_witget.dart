// lib/mobileFeatures/mobile_comic_details/widget/title_chapters_widget.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Mevcut TitleChaptersWidget'ınız
class TitleChaptersWidget extends StatelessWidget {
  final String? seriesOrBookId;
  final bool? isOwner;
  final bool? isBook;

  const TitleChaptersWidget(
      {Key? key, this.isOwner, this.isBook, this.seriesOrBookId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Bu widget'ın içeriği, delegate içinde kullanılacak.
    return Container(
      // Arka plan rengi, yapıştığında içeriğin arkasında kalmasın diye önemli.
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Row(
        children: [
          Text(
            "Bölümler",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (isOwner == true || isBook == true)
            TextButton.icon(
              onPressed: () {
                context.push('/myAccount/books/$seriesOrBookId/chapters');
              },
              icon: const Icon(Icons.edit),
              label: const Text("Bölümleri Yönet"),
            ),
        ],
      ),
    );
  }
}

// --- YENİ EKLENEN DELEGATE SINIFI ---
// Bu sınıf, TitleChaptersWidget'ın bir Sliver olarak nasıl davranacağını tanımlar.
// lib/mobileFeatures/mobile_details/widget/sliver_chapter_header_delegate.dart

class SliverChapterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  SliverChapterHeaderDelegate({
    required this.child,
    this.height = 56.0, // başlık yüksekliği: ihtiyaca göre ayarla
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Yükseklik mutlaka kısıtlanmış olmalı
    return SizedBox(
      height: height,
      child: Material(
        // ink efektleri vs için güvenli
        color: Colors.transparent,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverChapterHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
