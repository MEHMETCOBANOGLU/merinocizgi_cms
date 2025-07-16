// lib/mobileFeatures/mobile_home/widget/carousel_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merinocizgi/core/theme/colors.dart';

// Bu widget artık dikey bir "Top List" gösterecek.
class CarouselTopWidget extends StatelessWidget {
  final String title;
  final List<Widget> children; // Bu, _TopSeriesListItem widget'larını tutacak.
  final VoidCallback? onSeeMore;

  const CarouselTopWidget({
    super.key,
    required this.title,
    required this.children,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve "Daha Fazla" butonu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                title,
                style: GoogleFonts.oswald(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (onSeeMore != null)
              InkWell(
                onTap: onSeeMore,
                child: Text(
                  'Tümünü Gör',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Dikey Liste
        // ListView.separated, her eleman arasına otomatik olarak bir ayırıcı koyar.
        ListView.separated(
          itemCount: children.length,
          padding: EdgeInsets.zero, // Dışarıdan padding'i yöneteceğiz.
          shrinkWrap: true, // Üstündeki Column'a yüksekliğini bildirmesi için
          physics:
              const NeverScrollableScrollPhysics(), // Kaydırmayı ana SingleChildScrollView yapsın
          itemBuilder: (context, index) {
            return children[index];
          },
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFEEEEEE), // Çok hafif bir ayırıcı rengi
            indent: 50, // Numara ve resim kadar boşluk bırak
            endIndent: 50,
          ),
        ),
      ],
    );
  }
}
