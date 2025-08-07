import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/mobileFeatures/shared/providers/bottom_bar_provider.dart';
import 'package:merinocizgi/mobileFeatures/shared/view/mobile_main_layout.dart';
import 'package:merinocizgi/mobileFeatures/shared/widget.dart/add_post_sheet.dart';

class BottomBarWidget extends ConsumerStatefulWidget {
  final List<BottomBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const BottomBarWidget({
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  ConsumerState<BottomBarWidget> createState() => _BottomBarWidgetState();
}

class _BottomBarWidgetState extends ConsumerState<BottomBarWidget> {
  // ↓ Alt bar’ı ölçmek için key
  final GlobalKey _barKey = GlobalKey();

  void _measureAndSaveHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _barKey.currentContext;
      final h = ctx?.size?.height;
      if (h != null && h > 0) {
        final current = ref.read(bottomBarHeightProvider);
        // Gereksiz rebuild’leri azaltmak için değişmişse yaz.
        if (current == null || (current - h).abs() > 1.0) {
          ref.read(bottomBarHeightProvider.notifier).state = h;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _measureAndSaveHeight();
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        key: _barKey,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.6),
            width: 4,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Eşit aralık bırak
              children: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final isSelected = (widget.selectedIndex == index);

                final prioritizedCodePoint = 0xE758;

                final isPrioritized =
                    item.icon.codePoint == prioritizedCodePoint;

                // --- ANA DEĞİŞİKLİK BURADA ---
                // IconButton'ı AnimatedContainer ile sarmalıyoruz.
                return ClipOval(
                  child: BackdropFilter(
                    // Bu, arkasındaki her şeyi blurlayan sihirli kısımdır.
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: 50, // Her ikon için sabit bir dokunma alanı
                      height: 50,
                      decoration: BoxDecoration(
                        // Eğer seçili ise arka plan rengini ayarla, değilse şeffaf yap.
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        // (Opsiyonel) Dairenin kenarına ince bir parlama efekti
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                width: 1.5)
                            : null,
                      ),
                      child: IconButton(
                        icon: Icon(item.icon),
                        iconSize: 28,
                        color:
                            isSelected ? item.activeColor : item.inactiveColor,
                        onPressed: () {
                          print(item.icon);
                          widget.onItemSelected(index);
                        },
                        splashColor: item.activeColor.withOpacity(0.2),
                        highlightColor: item.activeColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomBarItem {
  final IconData icon;
  final Color activeColor;
  final Color inactiveColor;

  BottomBarItem({
    required this.icon,
    required this.activeColor, // Zorunlu hale getirelim
    required this.inactiveColor, // Zorunlu hale getirelim
  });
}

// Navigasyon mantığını buraya taşıyoruz.
void onItemTapped(int index, WidgetRef ref, BuildContext context) {
  // 1. Global state'i güncelle.
  ref.read(selectedBottomBarIndexProvider.notifier).state = index;

  // 2. İlgili sayfaya yönlendir.
  switch (index) {
    case 0:
      context.go('/');
      break;
    case 1:
      context.go('/social'); // Örnek bir rota
      break;
    case 2:
      final safeBottom = MediaQuery.of(context).padding.bottom;
      final measuredBarH = ref.read(bottomBarHeightProvider);
      // Ölçüm gelmediyse makul bir tahmin (56) + 8px tampon
      final barHeight = (measuredBarH ?? (56.0)) + 8.0;

      final bottomMargin = safeBottom + barHeight; // ← Dinamik alt boşluk

      showModalBottomSheet<void>(
        context: context,
        backgroundColor:
            Colors.transparent, // Arka plan tamamen transparan olmalı
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxHeight: 270,
        ),
        builder: (BuildContext context) {
          // --- 1. DIŞ SARMALAYICI: KAPATMA ALANI ---
          // Bu dış GestureDetector, tüm modal alanını kaplar.
          // Boş bir alana dokunulduğunda modal'ı kapatır.
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                // GestureDetector'ın dokunmaları algılayabilmesi içins
                // bir renge sahip olması gerekir. Transparan renk işimizi görür.
                color: Colors.transparent,

                child: Align(
                  alignment: Alignment.bottomCenter,
                  // --- 2. İÇ SARMALAYICI: DOKUNMAYI ENGELLEYİCİ ---
                  // Bu iç GestureDetector, görünen içeriğin üzerindedir.
                  // Görevi, içeriğe yapılan dokunmaları "tüketmek" ve
                  // dıştaki kapatma GestureDetector'ına ulaşmasını engellemektir.
                  child: GestureDetector(
                    onTap: () {}, // Hiçbir şey yapma, sadece dokunmayı yut.
                    child: Container(
                      // Görünen modal içeriğimiz.
                      margin: EdgeInsets.fromLTRB(20, 0, 20, bottomMargin),
                      decoration: BoxDecoration(
                        // color: AppColors.primary.withOpacity(0.1),
                        color: AppColors.primary.withOpacity(0.85),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 1.5),
                      ),
                      width: MediaQuery.of(context).size.width * 0.77,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Divider(
                              color: Colors.white38,
                              thickness: 2,
                              indent: 100,
                              endIndent: 100,
                            ),
                            ListView(shrinkWrap: true, children: [
                              ListTile(
                                leading: const Icon(BoxIcons.bx_book_add,
                                    color: Colors.white),
                                title: Text('Yeni Çizgi Roman Ekle',
                                    style: AppTextStyles.oswaldText),
                                onTap: () {
                                  context.push('/addWebtoon');
                                },
                              ),
                              ListTile(
                                leading: const Icon(BoxIcons.bxs_book_add,
                                    color: Colors.white),
                                title: Text('Yeni Kitap Ekle',
                                    style: AppTextStyles.oswaldText),
                                onTap: () {
                                  context.push('/create-book');
                                },
                              ),
                              ListTile(
                                leading: const Icon(MingCute.quill_pen_fill,
                                    // MingCute.quill_pen_line,
                                    color: Colors.white),
                                title: Text('Durum Paylaş',
                                    style: AppTextStyles.oswaldText),
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(); // önce açık modalı kapat
                                  context.go('/social');
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    // Sayfa geçişi tamamlandıktan sonra çalışır
                                    Future.delayed(
                                        const Duration(milliseconds: 100), () {
                                      addPostSheetfunc(context, ref);
                                    });
                                  });
                                },
                              ),
                            ])
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      break;
    case 3:
      context.go('/search');
      break;
    case 4:
      context.go('/myAccount');
      break;
  }
}
