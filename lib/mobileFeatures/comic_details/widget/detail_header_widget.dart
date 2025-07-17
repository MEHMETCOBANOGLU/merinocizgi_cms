import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merinocizgi/core/theme/colors.dart';

class DetailHeaderWidget extends StatefulWidget {
  final String urlImage;
  final String authorName;
  final String authorId;
  final String title;
  final String synopsis;
  final String seriesId;
  final double rating;

  const DetailHeaderWidget({
    super.key,
    required this.urlImage,
    required this.authorName,
    required this.authorId,
    required this.title,
    required this.synopsis,
    required this.seriesId,
    required this.rating,
  });

  @override
  State<DetailHeaderWidget> createState() => _DetailHeaderWidgetState();
}

class _DetailHeaderWidgetState extends State<DetailHeaderWidget> {
  bool isLiked = false;
  int rating = 0;
  bool isReadMore = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // --- METİN HESAPLAMA MANTIĞI ---
    // TextPainter'ı build metodunun en başında oluşturup,
    // metnin kaplayacağı alanı önceden hesaplıyoruz.
    final textSpan = TextSpan(
      text: widget.synopsis,
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
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
      textDirection: TextDirection.ltr,
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
                  image: NetworkImage(widget.urlImage),
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
                              widget.title,
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
                                context.push('/UserProfile/${widget.authorId}');
                                print('Author: ${widget.authorName}');
                              },
                              child: Text(
                                '@${widget.authorName}',
                                style: GoogleFonts.oswald(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.visibility,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '89,200',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
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
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(7),
                              minimumSize: const Size.square(25),
                              backgroundColor: Colors.transparent,
                              overlayColor: AppColors.primary,
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {},
                            // icon: const Icon(Icons.add_circle),
                            icon: const Icon(
                              Icons.bookmark_add,
                              size: 15,
                            ),
                            label: const Text('Kaydet',
                                style: TextStyle(fontSize: 14))),
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
                    Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                isLiked = !isLiked;
                                rating = isLiked ? 5 : 0;
                              });
                              submitRating(widget.seriesId, rating);
                            },
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 30,
                              color: isLiked ? Colors.red : Colors.red,
                            ),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> submitRating(String seriesId, int rating) async {
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
