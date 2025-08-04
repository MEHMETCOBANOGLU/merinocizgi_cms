import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/providers/comment_providers.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/index.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/controller/book_controller.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/view/comment_composer.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comments/widget/comment_list.dart';
import 'package:merinocizgi/mobileFeatures/mobile_details/controller/library_controller.dart';
import 'package:merinocizgi/mobileFeatures/mobile_details/controller/userRatingProvider.dart';
import 'package:merinocizgi/mobileFeatures/mobile_details/widget/rating_button.dart';

import 'package:merinocizgi/mobileFeatures/mobile_details/widget/save_to_list_dialog.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/liquid_glass_%C4%B1con_button.dart';

class DetailHeaderWidget extends ConsumerStatefulWidget {
  final String seriesOrBookId;
  final bool isBook;
  const DetailHeaderWidget({
    super.key,
    required this.seriesOrBookId,
    this.isBook = false,
  });

  @override
  ConsumerState<DetailHeaderWidget> createState() => _DetailHeaderWidgetState();
}

class _DetailHeaderWidgetState extends ConsumerState<DetailHeaderWidget> {
  bool isLiked = false;
  int rating = 0;
  bool isReadMore = false;

  final GlobalKey _cardKey = GlobalKey(); // ★ CHANGED: kartı ölçmek için
  double _cardHeight = 0; // ★ CHANGED: ölçülen yükseklik

  void _showSaveToListDialog() {
    showDialog(
      context: context,
      builder: (context) => SaveToListDialog(
        seriesId: widget.seriesOrBookId,
        isBook: widget.isBook,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seriesAsync = ref.watch(seriesProvider(widget.seriesOrBookId));
    final bookAsync = ref.watch(bookProvider(widget.seriesOrBookId));

    // final isOwner = bookAsync.when(
    //   data: (book) => book['authorId'] == authUser?.uid,
    //   loading: () => false,
    //   error: (_, __) => false,
    // );

    return seriesAsync.when(
      data: (seriesDoc) {
        if (seriesDoc.exists) {
          final data = seriesDoc.data() as Map<String, dynamic>;
          return _buildDetailWidget(data);
        } else {
          return bookAsync.when(
            data: (bookDoc) {
              if (bookDoc.exists) {
                final data = bookDoc.data() as Map<String, dynamic>;
                return _buildDetailWidget(data);
              }
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

  Widget _buildDetailWidget(Map<String, dynamic> data) {
    final authUser = FirebaseAuth.instance.currentUser;
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top; // ★ CHANGED: safe area
    final authStateAsync = ref.watch(authStateProvider);

    // ★ CHANGED: Kart ölçümü – post-frame’de 1px toleransla setState
    void _scheduleMeasureCard() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _cardKey.currentContext;
        if (ctx != null) {
          final render = ctx.findRenderObject();
          if (render is RenderBox) {
            final newHeight = render.size.height;
            if (newHeight > 0 && (newHeight - _cardHeight).abs() > 1.0) {
              setState(() => _cardHeight = newHeight);
            }
          }
        }
      });
    }

    // --- DATA ---
    final title = data['title'] ?? 'Başlık Yok';
    final synopsis = data['summary'] ?? data['description'] ?? 'Açıklama Yok';
    final urlImage = data['squareImageUrl'] ?? data['coverImageUrl'] ?? '';
    final authorName = data['authorName'] ?? 'Bilinmeyen Yazar';
    final authorId = data['authorId'] ?? '';
    final averageRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
    final viewCount = data['viewCount'] as int? ?? 0;
    final formattedViewCount = NumberFormat.compact().format(viewCount);
    final tags = data['tags'] as List<dynamic>? ?? [];

    final userRating = ref.watch(
      userRatingProvider((
        id: widget.seriesOrBookId,
        type: widget.isBook ? 'books' : 'series'
      )),
    );

    // --- METİN HESABI (fallback) ---
    final textSpan = TextSpan(
        text: synopsis,
        style: const TextStyle(color: Colors.grey, fontSize: 12));
    final maxTextWidth = size.width * 0.9;

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
      maxLines: isReadMore ? 1000 : 3,
    )..layout(maxWidth: maxTextWidth);

    final double textHeight = textPainter.size.height;

    final textPainterForCheck = TextPainter(
      text: textSpan,
      maxLines: 3,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxTextWidth);

    final bool shouldShowReadMore = textPainterForCheck.didExceedMaxLines;

    // --- Stack sabitleri (tasarımın aynı kalması için) ---
    final double bgHeight = size.height * 0.32; // arka plan görseli yüksekliği
    final double topOffset = (size.height * 0.35) -
        (size.height * 0.1); // kartın üstten pozisyonu (=0.25h)

    // --- İlk frame için kaba tahmin, ölçüm gelince _cardHeight kullanacağız ---
    // ★ CHANGED: Tahmini kart yüksekliği – başlık/ikon/sinopsis başlığı/padding + text + readmore + etiketler
    const double fixedHeadRows = 72.0;
    const double sectionHeader = 28.0;
    const double verticalPadding = 22.0;
    const double gaps = 12.0;
    final double tagsHeight = (widget.isBook && tags.isNotEmpty) ? 36.0 : 0.0;
    final double readMoreHeight = shouldShowReadMore ? 20.0 : 0.0;

    final double estimatedCardHeight = fixedHeadRows +
        sectionHeader +
        verticalPadding +
        gaps +
        textHeight +
        readMoreHeight +
        tagsHeight;

    // ★ CHANGED: Ölçüm varsa onu kullan; yoksa fallback
    final double cardH = _cardHeight > 0 ? _cardHeight : estimatedCardHeight;

    // ★ CHANGED: totalHeaderHeight’i gerçek karta göre hesapla
    final double totalHeaderHeight = math.max(
      bgHeight,
      topOffset + cardH + safeTop,
    );

    // ★ CHANGED: Her build’den sonra gerçek yüksekliği ölç (sonsuz döngüye girmez; tolerans var)
    _scheduleMeasureCard();

    return SizedBox(
      height: totalHeaderHeight,
      width: size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Container(
              height: bgHeight, // ★ CHANGED: sabit değeri değişkende kullandık
              width: size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(urlImage), fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: topOffset, // ★ CHANGED: sabit değeri değişkende kullandık
            child: Container(
              key: _cardKey, // ★ CHANGED: ölçüm için key
              width: size.width * .9,
              decoration: BoxDecoration(
                color: AppColors.darkColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.9),
                      offset: const Offset(0, 6),
                      blurRadius: 6),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // SOLDaki blok: bounded genişlik vermek için Expanded
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    title!,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.oswald(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  RatingButton(
                                    id: widget.seriesOrBookId,
                                    isBook: widget.isBook,
                                    averageRating: averageRating,
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.visibility,
                                          color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        formattedViewCount,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // BURADA Expanded KALDIRILDI
                              Row(
                                // Spacer yerine spaceBetween ya da sabit boşluk kullanın
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        context.push('/UserProfile/$authorId'),
                                    child: Flexible(
                                      // Expanded değil, Flexible
                                      child: Text(
                                        '@$authorName',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.oswald(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  ref
                                      .watch(isContentInAnyLibraryProvider(
                                        (
                                          widget.seriesOrBookId,
                                          widget.isBook ? 'books' : 'series'
                                        ),
                                      ))
                                      .when(
                                        data: (isSaved) {
                                          if (isSaved) {
                                            return ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 10),
                                                minimumSize: const Size(0, 0),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    const VisualDensity(
                                                        horizontal: -3,
                                                        vertical: -1.5),
                                                backgroundColor: AppColors
                                                    .primary
                                                    .withOpacity(0.2),
                                                side: BorderSide(
                                                    color: AppColors.primary),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                              ),
                                              onPressed: _showSaveToListDialog,
                                              icon: const Icon(
                                                  Icons.bookmark_added,
                                                  size: 15,
                                                  color: AppColors.primary),
                                              label: const Text('Kaydedildi',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          AppColors.primary)),
                                            );
                                          } else {
                                            return ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 10),
                                                minimumSize: const Size(0, 0),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    const VisualDensity(
                                                        horizontal: -3,
                                                        vertical: -1.5),
                                                backgroundColor:
                                                    Colors.transparent,
                                                side: const BorderSide(
                                                    color: Colors.white24),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                              ),
                                              onPressed: () {
                                                if (authStateAsync
                                                        .value?.user ==
                                                    null) {
                                                  context.push('/mobileLogin');
                                                  return;
                                                }
                                                _showSaveToListDialog();
                                              },
                                              icon: const Icon(
                                                  Icons.bookmark_add_outlined,
                                                  size: 15),
                                              label: const Text('Kaydet',
                                                  style:
                                                      TextStyle(fontSize: 10)),
                                            );
                                          }
                                        },
                                        loading: () => const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: SizedBox(
                                              width: 15,
                                              height: 15,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2)),
                                        ),
                                        error: (error, stack) => IconButton(
                                          icon: const Icon(Icons.error_outline,
                                              color: Colors.red),
                                          onPressed: () {},
                                        ),
                                      ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // const SizedBox(
                        //     width:
                        //         12), // Dış Row'daki eski Spacer yerine küçük boşluk
                        // // Sağdaki bileşenler
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
                        IconButton(
                          padding: EdgeInsets.zero,
                          // constraints: const BoxConstraints.tightFor(
                          //     width: 28, height: 28),
                          visualDensity:
                              const VisualDensity(horizontal: -4, vertical: -4),
                          // iconSize: 22,
                          onPressed: () {
                            _commentWidget(
                                ref, authUser, context, widget.seriesOrBookId);
                          },
                          icon: const Icon(
                            AntDesign.comment_outline,
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
                          onTap: () {
                            setState(() => isReadMore = !isReadMore);
                            _scheduleMeasureCard(); // ★ CHANGED: toggle sonrası yeniden ölç
                          },
                          child: Text(
                            isReadMore ? 'Daha az göster' : 'daha fazla',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 12),
                          ),
                        ),
                      ),
                    if (widget.isBook) const SizedBox(height: 8),
                    if (widget.isBook)
                      Wrap(
                        spacing: 4, // gerçek boşluk
                        runSpacing: 4,
                        children: tags
                            .map((tag) => Chip(
                                  label: Text(tag,
                                      style: const TextStyle(fontSize: 12)),
                                  labelPadding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(
                                    horizontal: -4, // daha kompakt
                                    vertical: -4,
                                  ),
                                  padding: EdgeInsets.zero, // Chip iç dolgusu
                                ))
                            .toList(),
                      ),
                    if (widget.isBook) const SizedBox(height: 8),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LiquidGlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () => context.pop(),
                      ),
                      LiquidGlassIconButton(
                        icon: Icons.share_outlined,
                        onPressed: () {/* Paylaşma mantığı */},
                      ),
                    ],
                  ),
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
      return Future.error('Kullanıcı oturum açılmamış.');
    }
    final ratingRef = FirebaseFirestore.instance
        .collection('series')
        .doc(seriesId)
        .collection('ratings')
        .doc(user.uid);

    await ratingRef.set({
      'rating': rating,
      'ratedAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
    });
  }

  Future<void> showRatingDialog(
    BuildContext context,
    String seriesId,
    WidgetRef ref,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final contentType = widget.isBook ? 'books' : 'series';
    final contentId = widget.seriesOrBookId;

    final doc = await FirebaseFirestore.instance
        .collection(contentType)
        .doc(contentId)
        .collection('ratings')
        .doc(user.uid)
        .get();

    final initialRating = (doc.data()?['rating'] as num?)?.toDouble() ?? 0.0;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                .read(userRatingProvider((id: contentId, type: contentType))
                    .notifier)
                .submitRating(rating);

            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Puanınız kaydedildi.")),
            );
          },
        ),
      ),
    );
  }
}

_commentWidget(
    WidgetRef ref, User? user, BuildContext context, String seriesOrBookId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final viewInsets = MediaQuery.of(context).viewInsets;
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // ✅ Klavye yüksekliği kadar boşluk
        ),
        child: DraggableScrollableSheet(
            initialChildSize: 0.5, // ilk açılışta ekranın %50’si
            minChildSize: 0.3, // en küçük %30
            maxChildSize: 0.95, // en büyük %95
            expand: false, // içerik kadar büyüsün
            builder: (context, scrollCtrl) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ Kapsama alanı kadar
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      'Yorumlar',
                      style: AppTextStyles.oswaldText,
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        children: [
                          CommentList(
                            contentType: 'books',
                            contentId: seriesOrBookId,
                            onReplyTap: (c) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom, // ✅ Klavye yüksekliği kadar boşluk
                                  ),
                                  child: CommentComposer(
                                    hint:
                                        '${c.userName} kullanıcısına cevap ver…',
                                    onSend: (text) async {
                                      if (user == null) {
                                        context.push('/mobileLogin');
                                        return;
                                      }
                                      await ref.read(addCommentProvider((
                                        contentType: 'books',
                                        contentId: seriesOrBookId,
                                        parentId: c.id,
                                        userId: user.uid,
                                        userName:
                                            user.displayName ?? 'Kullanıcı',
                                        userPhoto: user.photoURL,
                                        text: text,
                                      )).future);
                                      if (Navigator.canPop(context))
                                        Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                              height: 80), // composer için nefes payı
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    CommentComposer(
                      onSend: (text) async {
                        if (user == null) {
                          // login sayfasına yönlendir vb.
                          context.push('/mobileLogin');
                          return;
                        }
                        await ref.read(addCommentProvider((
                          contentType: 'books', // veya 'series' / 'episodes'
                          contentId: seriesOrBookId,
                          parentId: null,
                          userId: user.uid,
                          userName: user.displayName ?? 'Kullanıcı',
                          userPhoto: user.photoURL,
                          text: text,
                        )).future);
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              );
            }),
      );
    },
  );
}
