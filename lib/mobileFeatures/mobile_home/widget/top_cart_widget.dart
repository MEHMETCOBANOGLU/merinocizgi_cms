import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopCardWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int rank; // Sıralama numarası (1, 2, 3...)
  final int viewCount;
  final VoidCallback onTap;

  const TopCardWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.rank,
    required this.viewCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                // Stack'in, çocuklarının kendi sınırlarının dışına taşmasına izin ver.
                clipBehavior: Clip.none,
                children: [
                  // 1. Arka Plan Görseli
                  // Bu, tüm alanı kaplayacak olan ana resimdir.
                  Positioned.fill(
                    child: ClipRRect(
                      // Kenarları yuvarlatmak için
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        // Hata ve yükleme durumları için placeholder'lar eklemek iyi bir pratiktir.
                        errorBuilder: (c, e, s) =>
                            Container(color: Colors.grey[800]),
                        loadingBuilder: (c, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2));
                        },
                      ),
                    ),
                  ),

                  // 2. Sıralama Numarası (Rank)
                  // Bu, görselin üzerine konumlandırılacak olan metindir.
                  Positioned(
                    // left: -8, // Sol kenardan -8 piksel DIŞARIYA taşı.
                    bottom: -21, // Alt kenardan -15 piksel DIŞARIYA taşı.
                    child: Text(
                      '$rank',
                      style: GoogleFonts.oswald(
                        // Oswald gibi cesur bir font çok yakışır
                        fontSize: 30, // Boyutu büyütelim ki etkili dursun
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.visibility,
                  size: 18,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  '$viewCount',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
