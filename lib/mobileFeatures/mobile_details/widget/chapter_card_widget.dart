import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merinocizgi/core/theme/colors.dart';

class ChapterCardWidget extends StatelessWidget {
  final String seriesId;
  final String? title;
  final String chapter;
  final String episodeId;
  final String? urlImage;
  final bool isBook;
  final bool? isOwner;

  const ChapterCardWidget({
    super.key,
    required this.seriesId,
    this.title,
    required this.chapter,
    required this.episodeId,
    this.urlImage,
    required this.isBook,
    this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    // ★ CHANGED: Boş/whitespace URL koruması
    final bool hasImage = (urlImage != null && urlImage!.trim().isNotEmpty);

    return GestureDetector(
      onTap: () {
        if (isBook) {
          context.push('/book-reader/$seriesId/$episodeId');
        } else {
          context.push('/comic-reader/$seriesId/$episodeId');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary),
        ),
        padding: hasImage
            ? const EdgeInsets.all(8)
            : const EdgeInsets.all(14), // ★ CHANGED
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment:
              isBook ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            if (hasImage) // ★ CHANGED
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  // ★ CHANGED: DecorationImage yerine doğrudan Image.widget kullan,
                  // errorBuilder burada çalışır ve boş/yanlış URL patlatmaz.
                  child: Image.network(
                    urlImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(
                      color: Colors.black26,
                      child: Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.white70),
                      ),
                    ),
                  ),
                ),
              ),
            if (hasImage) const SizedBox(width: 12),

            // Metin kısmı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bölüm etiketi
                  Text(
                    'Bölüm $chapter',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Başlık (isBook == false ise gösteriyorsunuz; aynen korunuyor)
                  if (isBook == false)
                    // ★ CHANGED: AutoSizeText için küçük iyileştirmeler
                    AutoSizeText(
                      title ?? '',
                      maxLines: 2, // 2 satıra kadar sığdır
                      minFontSize: 12, // buraya kadar küçülsün
                      overflow: TextOverflow.ellipsis,
                      softWrap: true, // ★ CHANGED
                      stepGranularity: 0.5, // ★ CHANGED: daha akıcı küçültme
                      style: GoogleFonts.oswald(
                        color: Colors.white,
                        fontSize: 14, // hedef font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            if (isBook && isOwner == true)
              IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.white),
                onPressed: () => context.push(
                    '/myAccount/books/$seriesId/chapters/$episodeId/edit'),
              ),
          ],
        ),
      ),
    );
  }
}
