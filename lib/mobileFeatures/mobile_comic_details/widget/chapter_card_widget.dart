import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/theme/colors.dart';

class ChapterCardWidget extends StatelessWidget {
  final String seriesId;
  final String title;
  final String chapter;
  final String episodeId;
  final String? urlImage;
  final bool isBook;
  final bool? isOwner;

  const ChapterCardWidget({
    super.key,
    required this.seriesId,
    required this.title,
    required this.chapter,
    required this.episodeId,
    this.urlImage,
    required this.isBook,
    this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('SeriesId: $seriesId , title: $title, chapter: $episodeId');
        context.push('/reader/$seriesId/$episodeId');
      },
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary,
            ),
          ),
          padding: urlImage != null
              ? const EdgeInsets.all(8)
              : const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: isBook
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              if (urlImage != null)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: Image.network(
                        urlImage!,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ).image,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              if (urlImage != null)
                const SizedBox(width: 12), // varsa boşluk bırak
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bölüm $chapter',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              if (isBook && isOwner == true)
                IconButton(
                  icon: const Icon(
                    Icons.edit_note,
                    color: Colors.white,
                  ),
                  onPressed: () => context.push(
                      '/myAccount/books/$seriesId/chapters/${episodeId}/edit'),
                ),
            ],
          )),
    );
  }
}
