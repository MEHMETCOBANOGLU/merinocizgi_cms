import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/comic_details/controller/library_controller.dart';
import 'package:merinocizgi/mobileFeatures/comic_details/controller/userRatingProvider.dart';

class DetailHeaderWidget extends ConsumerStatefulWidget {
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
      builder: (context) => _SaveToListDialog(seriesId: widget.seriesId),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final seriesAsync = ref.watch(seriesProvider(widget.seriesId));
    final userRating = ref.watch(userRatingProvider(widget.seriesId));

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
                        userRating.when(
                          data: (rating) => InkWell(
                            onTap: () {
                              showRatingDialog(context, widget.seriesId, ref);
                            },
                            child: Icon(
                              rating != null ? Icons.star : Icons.star_border,
                              color: Colors.yellow,
                            ),
                          ),
                          loading: () =>
                              const CircularProgressIndicator(strokeWidth: 1),
                          error: (_, __) =>
                              const Icon(Icons.error, color: Colors.red),
                        ),
                        const SizedBox(width: 4),
                        seriesAsync.when(
                          data: (seriesDoc) {
                            final data =
                                seriesDoc.data() as Map<String, dynamic>;
                            final averageRating =
                                (data['averageRating'] ?? 0).toDouble();

                            return Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            );
                          },
                          loading: () =>
                              const CircularProgressIndicator(strokeWidth: 1),
                          error: (e, _) => const Text('0.0',
                              style: TextStyle(color: Colors.white)),
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
                        ref
                            .watch(isComicInAnyLibraryProvider(widget.seriesId))
                            .when(
                              // data: provider'dan gelen 'true' veya 'false' sonucudur.
                              data: (isSaved) {
                                // Eğer çizgi roman ZATEN kayıtlıysa (isSaved == true)
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
                                    icon: Icon(
                                      Icons
                                          .bookmark_added, // İkonu değiştiriyoruz
                                      size: 15,
                                      color: AppColors.primary,
                                    ),
                                    label: Text(
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
                                    onPressed: _showSaveToListDialog,
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

class _SaveToListDialog extends ConsumerStatefulWidget {
  final String seriesId;
  const _SaveToListDialog({required this.seriesId});

  // State'i oluşturan satır doğru.
  @override
  ConsumerState<_SaveToListDialog> createState() => _SaveToListDialogState();
}

class _SaveToListDialogState extends ConsumerState<_SaveToListDialog> {
  final _textController = TextEditingController();
  final Set<String> _selectedLibraryIds = {};
  bool _isCreatingNewList = false;
  bool _isPrivate = false;
  bool _hasValidationError = false;

  // "Daha Sonra Oku" listesinin ID'sini tutmak için bir değişken
  String? _defaultLibraryId;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_selectedLibraryIds.isEmpty) {
      setState(() => _hasValidationError = true);
      return;
    }

    ref.read(libraryControllerProvider.notifier).addSeriesToLibraries(
          widget.seriesId,
          _selectedLibraryIds.toList(),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seri, seçilen listelere eklendi.")));
  }

  void _handleCreateNewLibrary() async {
    final name = _textController.text.trim();
    if (name.isEmpty) return;

    // Controller'dan yeni liste oluşturmasını iste.
    final newLibraryId = await ref
        .read(libraryControllerProvider.notifier)
        .createNewLibrary(name, _isPrivate);

    _textController.clear();
    setState(() {
      _isCreatingNewList = false;
      // Yeni oluşturulan listeyi otomatik olarak seçili hale getir.
      if (newLibraryId != null) {
        _selectedLibraryIds.add(newLibraryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final librariesAsync = ref.watch(userLibrariesProvider);

    return AlertDialog(
      title: const Center(child: Text("Listeye Ekle")),
      content: SizedBox(
        width:
            400, // Diyaloğa sabit bir genişlik vermek daha iyi bir görünüm sağlar
        child: librariesAsync.when(
          data: (libraries) {
            // Kullanıcının oluşturduğu diğer listeler
            final customLibraries =
                libraries.where((doc) => doc.id != _defaultLibraryId).toList();

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- DİNAMİK "DİĞER LİSTELER" BÖLÜMÜ ---

                  if (customLibraries.isEmpty && !_isCreatingNewList)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text("Henüz bir listeniz yok.",
                          style: TextStyle(fontStyle: FontStyle.italic)),
                    ),

                  ...customLibraries.map((lib) => _buildLibraryTile(lib)),

                  if (_hasValidationError)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text("Lütfen en az bir liste seçin.",
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),

                  const SizedBox(height: 16),

                  if (_isCreatingNewList)
                    _buildCreateNewListSection()
                  else
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Yeni Liste Oluştur"),
                      onPressed: () =>
                          setState(() => _isCreatingNewList = true),
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => const Text("Listeler yüklenemedi."),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _handleSave,
          child: const Text("Kaydet"),
        ),
      ],
    );
  }

  // --- GÜNCELLENMİŞ 'buildLibraryTile' METODU ---
  Widget _buildLibraryTile(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final isSelected = _selectedLibraryIds.contains(doc.id);

    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: const CheckboxThemeData(
          shape: CircleBorder(), // DAİRE checkbox
          side: BorderSide(color: Colors.white54),
        ),
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Text(data['name']),
            const SizedBox(width: 8),
            // Sadece 'private' olanlar için kilit ikonu göster
            if ((data['isPrivate'] ?? true))
              Icon(Icons.lock, size: 14, color: Colors.grey[600]),
          ],
        ),
        value: isSelected,
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              _selectedLibraryIds.add(doc.id);
              _hasValidationError = false;
            } else {
              _selectedLibraryIds.remove(doc.id);
            }
          });
        },
      ),
    );
  }

  Widget _buildCreateNewListSection() {
    return Column(
      children: [
        TextField(
          controller: _textController,
          decoration: const InputDecoration(labelText: "Yeni liste adı"),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              const Text(
                "Özel",
              ),
              const SizedBox(width: 8),
              Icon(Icons.lock, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  activeTrackColor: AppColors.primary,
                  activeColor: AppColors.accent,
                  inactiveThumbColor: AppColors.primary,
                  value: _isPrivate,
                  onChanged: (val) => setState(() => _isPrivate = val),
                ),
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.7,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        backgroundColor: Colors.transparent),
                    onPressed: _handleCreateNewLibrary,
                    label: const Text("Ekle"),
                    icon: const Icon(Icons.add)),
              ),
              // IconButton(
              //   icon: const Icon(Icons.check, color: Colors.green),
              //   onPressed: _handleCreateNewLibrary,
              // )
            ],
          ),
        )
      ],
    );
  }
}
