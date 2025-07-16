import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merinocizgi/core/theme/colors.dart';

class DetailHeaderWidget extends StatefulWidget {
  final String urlImage;
  final String title;
  final String synopsis;
  final String seriesId;
  final double rating;

  const DetailHeaderWidget({
    super.key,
    required this.urlImage,
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
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * .45,
      width: size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Container(
              height: size.height * .35,
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
              height: size.height * .18,
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
                        Text(
                          widget.title,
                          style: GoogleFonts.oswald(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
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
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isLiked = !isLiked;
                              rating = isLiked ? 5 : 0;
                            });
                            submitRating(widget.seriesId, rating);
                          },
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.blue : Colors.grey,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sinopsis',
                      style: GoogleFonts.oswald(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.synopsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                            icon: const Icon(Icons.favorite_outline),
                            onPressed: () => context.pop(),
                            color: Colors.white,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.share_outlined),
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
