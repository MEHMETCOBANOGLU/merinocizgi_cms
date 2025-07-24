import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/theme/colors.dart';

class ChapterCardWidget extends StatelessWidget {
  final String seriesId;
  final String title;
  final String chapter;
  final String episodeId;
  final String? urlImage;

  const ChapterCardWidget({
    super.key,
    required this.seriesId,
    required this.title,
    required this.chapter,
    required this.episodeId,
    this.urlImage,
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
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
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
              const SizedBox(width: 12),
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
            ],
          )),
    );
  }
}
