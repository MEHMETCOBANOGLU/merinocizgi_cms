import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/theme/breakpoints.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/features/publish/widgets/review_and_publish.dart';

class SeriesInfoCard extends ConsumerWidget {
  final String title;
  final String summary;
  final String category1;
  final String category2;
  final dynamic squareImage; // String (URL) veya Uint8List olabilir
  final dynamic verticalImage; // String (URL) veya Uint8List olabilir
  final VoidCallback onPublishComplete;

  const SeriesInfoCard({
    super.key,
    required this.title,
    required this.summary,
    required this.category1,
    required this.category2,
    this.squareImage,
    this.verticalImage,
    required this.onPublishComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widthH = MediaQuery.of(context).size.width;
    final bool isWideScreen = widthH >= AppBreakpoints.tablet;

    Widget buildImage(dynamic imageData) {
      if (imageData is String) {
        return Image.network(imageData,
            width: 180, height: 260, fit: BoxFit.cover);
      } else if (imageData is Uint8List) {
        return Image.memory(imageData,
            width: 180, height: 260, fit: BoxFit.cover);
      }
      return Container(
          width: 180,
          height: 260,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
          child: Text('Seri',
              style: AppTextStyles.subheading.copyWith(color: Colors.black)),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          width: isWideScreen ? 500 : 400,
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.bg),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.bg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // DEĞİŞTİRİLDİ: Sadece squareImage için tek bir widget kullanıyoruz
                child: buildImage(squareImage),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.isNotEmpty ? title : 'Başlık Yok',
                      style: AppTextStyles.title.copyWith(color: Colors.black)),
                  Text('$category1 • $category2',
                      style: AppTextStyles.text
                          .copyWith(color: Colors.black, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(summary.isNotEmpty ? summary : 'Özet Yok',
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.text.copyWith(color: Colors.black)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (isWideScreen)
          publishButton(
              widthH: widthH, onPublishComplete: onPublishComplete, ref: ref),
      ],
    );
  }
}
