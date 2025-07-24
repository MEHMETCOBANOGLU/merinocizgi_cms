import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/controller/library_controller.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/controller/userRatingProvider.dart';
import 'dart:ui' as ui;

import 'package:merinocizgi/mobileFeatures/mobile_comic_details/widget/save_to_list_dialog.dart';

class DetailHeaderWidget extends ConsumerStatefulWidget {
  final String seriesOrBookId;
  const DetailHeaderWidget({
    super.key,
    required this.seriesOrBookId,
  });

  @override
  ConsumerState<DetailHeaderWidget> createState() => _DetailHeaderWidgetState();
}

class _DetailHeaderWidgetState extends ConsumerState<DetailHeaderWidget> {
  bool isLiked = false;
  int rating = 0;
  bool isReadMore = false;

  // --- YENİ DİYALOG FONKSİYONU ---
  void _showSaveToListDialog() {
    showDialog(
      context: context,
      builder: (context) => SaveToListDialog(seriesId: widget.seriesOrBookId),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    // --- YENİ VE DAHA TEMİZ PROVIDER'LAR ---
    // Hangi koleksiyona bakacağımızı bilmiyoruz, bu yüzden her ikisini de dinleyelim.
    // Ancak daha iyi bir yaklaşım, bir "contentProvider" oluşturmaktır.
    // Şimdilik bu yapı ile ilerleyelim.
    final seriesAsync = ref.watch(seriesProvider(widget.seriesOrBookId));
    final bookAsync = ref.watch(
        bookProvider(widget.seriesOrBookId)); // Bu provider'ı oluşturmalıyız.

    return seriesAsync.when(
      data: (seriesDoc) {
        // Eğer 'series' koleksiyonunda bulunduysa, onu kullan.
        if (seriesDoc.exists) {
          final data = seriesDoc.data() as Map<String, dynamic>;
          return _buildDetailWidget(data); // Veriyi doğrudan gönder
        } else {
          // 'series' koleksiyonunda yoksa, 'books' koleksiyonuna bak.
          return bookAsync.when(
            data: (bookDoc) {
              if (bookDoc.exists) {
                final data = bookDoc.data() as Map<String, dynamic>;
                return _buildDetailWidget(data); // Veriyi doğrudan gönder
              }
              // Hiçbir yerde bulunamadıysa
              return const Scaffold(
                  body: Center(child: Text("İçerik bulunamadı.")));
            },
            loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator())),
            error: (e, st) => Scaffold(body: Center(child: Text("Hata: $e"))),
          );
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text("Hata: $e"))),
    );
  }

// --- _buildDetailWidget SADELEŞTİRİLDİ ---
  // Bu widget artık ref'e veya provider'lara ihtiyaç DUYMUYOR.
  // Sadece kendisine verilen 'data'yı kullanarak UI çizer.
  Widget _buildDetailWidget(Map<String, dynamic> data) {
    final size = MediaQuery.of(context).size;
    final authStateAsync =
        ref.watch(authStateProvider); // Auth durumu hala gerekli

    // Veriyi 'data' map'inden alıyoruz.
    final title = data['title'] ?? 'Başlık Yok';
    final synopsis = data['summary'] ?? data['description'] ?? 'Açıklama Yok';
    final urlImage = data['squareImageUrl'] ?? data['coverImageUrl'] ?? '';
    final authorName = data['authorName'] ?? 'Bilinmeyen Yazar';
    final authorId = data['authorId'] ?? '';
    final averageRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
    final viewCount = data['viewCount'] as int? ?? 0;
    final formattedViewCount = NumberFormat.compact().format(viewCount);

    // Kullanıcının bu seriye verdiği oyu dinler.
    final userRating = ref.watch(userRatingProvider(widget.seriesOrBookId));

    // --- METİN HESAPLAMA MANTIĞI ---
    // TextPainter'ı build metodunun en başında oluşturup,
    // metnin kaplayacağı alanı önceden hesaplıyoruz.
    final textSpan = TextSpan(
      text: synopsis,
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
      maxLines:
          isReadMore ? 1000 : 3, // "Daha fazla" modunda satır limiti olmasın
    )..layout(maxWidth: size.width * 0.9 - 32); // Container genişliği - padding

    // Metnin kapladığı gerçek yüksekliği alıyoruz.
    final double textHeight = textPainter.size.height;
// "Devamını Oku" butonunun gösterilip gösterilmeyeceğini hesapla.
    // Bunun için metni, olması gereken maksimum satır limitiyle ölçüyoruz.
    final textPainterForCheck = TextPainter(
      text: textSpan,
      maxLines: 3, // <-- ANA DEĞİŞİKLİK BURADA: Limiti belirtiyoruz.
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.9 - 32); // Container genişliği - padding

    // 'didExceedMaxLines', şimdi metnin 3 satırdan uzun olup olmadığını doğru bir şekilde kontrol edecek.
    final bool shouldShowReadMore = textPainterForCheck.didExceedMaxLines;

    // --- YENİ VE DİNAMİK YÜKSEKLİK HESABI ---
    // Yüksekliği, metnin gerçek yüksekliğine göre hesaplıyoruz.
    // 'size.height * 0.22' gibi sabit değerler yerine,
    // (Başlık vb. için sabit yükseklik) + (Metnin dinamik yüksekliği) + (Padding'ler)
    const double baseHeight =
        121; // Başlık, ikonlar, boşluklar için tahmini sabit yükseklik
    final double containerHeight = baseHeight +
        textHeight +
        (shouldShowReadMore ? textHeight * 0.7 : textHeight * 0.5);
    final double totalHeaderHeight =
        (size.height * 0.38) - (size.height * 0.1) + containerHeight;

    return SizedBox(
      height: totalHeaderHeight,
      width: size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Container(
              height: size.height * .32,
              width: size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(urlImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: (size.height * .35) - (size.height * .1),
            child: Container(
              height: containerHeight,
              width: size.width * .9,
              decoration: BoxDecoration(
                color: AppColors.darkColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.9),
                    offset: const Offset(0, 6),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.oswald(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // context.push('/author/${widget.authorId}');
                                // /UserProfile/:authorId
                                context.push('/UserProfile/${authorId}');
                                print('Author: ${authorName}');
                              },
                              child: Text(
                                '@${authorName}',
                                style: GoogleFonts.oswald(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            if (authStateAsync.value?.user == null) {
                              context.push('/mobileLogin');
                              return;
                            }
                            print('Rating: $rating');
                            showRatingDialog(
                                context, widget.seriesOrBookId, ref);
                          },
                          child: Icon(
                            rating != null ? Icons.star : Icons.star_border,
                            color: Colors.yellow,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ortalama Puan
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            // Görüntülenme İkonu
                            const Icon(Icons.visibility,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            // Görüntülenme Sayısı
                            Text(
                              formattedViewCount, // '89,2K' gibi formatlanmış
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Sinopsis',
                          style: GoogleFonts.oswald(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        ref
                            .watch(isComicInAnyLibraryProvider(
                                widget.seriesOrBookId))
                            .when(
                              data: (isSaved) {
                                if (isSaved) {
                                  // Farklı bir buton gösteriyoruz.
                                  return ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(7),
                                      minimumSize: const Size.square(25),
                                      backgroundColor: AppColors.primary
                                          .withOpacity(
                                              0.2), // Rengi farklı olabilir
                                      side:
                                          BorderSide(color: AppColors.primary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    // Tıklandığında yine de listeleri yönetme diyaloğunu açabilir.
                                    onPressed: _showSaveToListDialog,
                                    icon: const Icon(
                                      Icons
                                          .bookmark_added, // İkonu değiştiriyoruz
                                      size: 15,
                                      color: AppColors.primary,
                                    ),
                                    label: const Text(
                                      'Kaydedildi', // Yazıyı değiştiriyoruz
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primary),
                                    ),
                                  );
                                }
                                // Eğer çizgi roman kayıtlı DEĞİLSE (isSaved == false)
                                else {
                                  // Orijinal "Kaydet" butonunu gösteriyoruz.
                                  return ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(7),
                                      minimumSize: const Size.square(25),
                                      backgroundColor: Colors.transparent,
                                      overlayColor: AppColors.primary,
                                      side: const BorderSide(
                                          color: Colors.white24),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (authStateAsync.value?.user == null) {
                                        context.push('/mobileLogin');
                                        return;
                                      }
                                      _showSaveToListDialog();
                                    },
                                    icon: const Icon(
                                      Icons.bookmark_add_outlined, // İkon
                                      size: 15,
                                    ),
                                    label: const Text(
                                      'Kaydet',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  );
                                }
                              },
                              // Provider veriyi yüklerken gösterilecek widget.
                              loading: () => const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 15,
                                  height: 15,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              // Hata durumunda gösterilecek widget.
                              error: (error, stack) => IconButton(
                                icon: const Icon(Icons.error_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  // Hata detayını göstermek için bir SnackBar vb. kullanılabilir.
                                },
                              ),
                            ),
                      ],
                    ),
                    Text.rich(
                      textSpan,
                      maxLines: isReadMore ? 1000 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (shouldShowReadMore)
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => setState(() => isReadMore = !isReadMore),
                          child: Text(
                            isReadMore ? 'Daha az göster' : 'daha fazla',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: SafeArea(
              child: SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                        color: Colors.white,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined, size: 30),
                        onPressed: () => context.pop(),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitRating(String seriesId, double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Kullanıcı giriş yapmamış, hata göster.
      return Future.error('Kullanıcı oturum açılmamış.');
    }

    // Kullanıcının oyunu, o serinin 'ratings' alt koleksiyonuna yaz.
    // Döküman ID'si olarak kullanıcının UID'sini kullanmak, her kullanıcının
    // sadece bir oy vermesini garanti eder (eski oyunun üzerine yazar).
    final ratingRef = FirebaseFirestore.instance
        .collection('series')
        .doc(seriesId)
        .collection('ratings')
        .doc(user.uid);

    await ratingRef.set({
      'rating': rating, // Kullanıcının verdiği puan (1-5)
      'ratedAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
    });

    // Geri kalan her şeyi Cloud Function halledecek!
  }

  Future<void> showRatingDialog(
    BuildContext context,
    String seriesId,
    WidgetRef ref,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('series')
        .doc(seriesId)
        .collection('ratings')
        .doc(user.uid)
        .get();

    final initialRating = (doc.data()?['rating'] ?? 3).toDouble();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Puanla')),
        content: RatingBar.builder(
          initialRating: initialRating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (rating) async {
            await ref
                .read(userRatingProvider(seriesId).notifier)
                .submitRating(rating);

            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Puanınız kaydedildi.")),
            );
          },
        ),
      ),
    );
  }
}
