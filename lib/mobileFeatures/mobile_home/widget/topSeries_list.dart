// Bu widget, Top 5 listesindeki tek bir satırı temsil eder.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopSeriesListItem extends StatelessWidget {
  final int rank; // Sıralama numarası (1, 2, 3...)
  final String imageUrl;
  final String title;
  final String category;
  final VoidCallback onTap;

  const TopSeriesListItem({
    super.key,
    required this.rank,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sıralamaya göre özel renkler (Altın, Gümüş, Bronz)
    final Color rankColor = (rank == 1)
        ? const Color(0xFFFFD700)
        : (rank == 2)
            ? const Color(0xFFC0C0C0)
            : (rank == 3)
                ? const Color(0xFFCD7F32)
                : Colors.grey[700]!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Sıralama Numarası
            SizedBox(
              width: 40,
              child: Text(
                '$rank',
                style: GoogleFonts.oswald(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: rankColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            // 2. Görsel
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    Container(width: 60, height: 80, color: Colors.grey[200]),
              ),
            ),
            const SizedBox(width: 16),
            // 3. Başlık ve Kategori (Column içinde)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // 4. Sağdaki ok ikonu (isteğe bağlı)
            // const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
