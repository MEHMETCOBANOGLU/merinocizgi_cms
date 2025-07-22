import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/shared/providers/bottom_bar_provider.dart';

class BottomBarWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Yüksekliği biraz artıralım
      // margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      // padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary, // Hafif daha açık bir koyu ton
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 7,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Eşit aralık bırak
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = (selectedIndex == index);

          final prioritizedCodePoint = 0xE758;

          final isPrioritized = item.icon.codePoint == prioritizedCodePoint;

          // --- ANA DEĞİŞİKLİK BURADA ---
          // IconButton'ı AnimatedContainer ile sarmalıyoruz.
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 50, // Her ikon için sabit bir dokunma alanı
            height: 50,
            decoration: BoxDecoration(
              // Eğer seçili ise arka plan rengini ayarla, değilse şeffaf yap.
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.transparent,
              // Daire şeklini ver.
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(item.icon),
              iconSize: 28,
              color: isSelected ? item.activeColor : item.inactiveColor,
              onPressed: () {
                print(item.icon);
                onItemSelected(index);
              },
              splashColor: item.activeColor.withOpacity(0.2),
              highlightColor: item.activeColor.withOpacity(0.1),
            ),
          );
        }),
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
      context.go('/library'); // Örnek bir rota
      break;
    case 2:
      showModalBottomSheet<void>(
        context: context,
        backgroundColor:
            Colors.transparent, // Arka plan tamamen transparan olmalı
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        builder: (BuildContext context) {
          // --- 1. DIŞ SARMALAYICI: KAPATMA ALANI ---
          // Bu dış GestureDetector, tüm modal alanını kaplar.
          // Boş bir alana dokunulduğunda modal'ı kapatır.
          return GestureDetector(
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
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 75),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: AppColors.primary,
                    ),
                    width: 305,
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
                                  color: AppColors.accent),
                              title: const Text('Yeni Çizgi Roman Ekle'),
                              onTap: () {
                                context.push('/addWebtoon');
                              },
                            ),
                            ListTile(
                              leading: const Icon(BoxIcons.bxs_book_add,
                                  color: AppColors.accent),
                              title: const Text('Yeni Kitap Ekle'),
                              onTap: () {
                                context.push('/create-book');
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                MingCute.quill_pen_fill,
                                // MingCute.quill_pen_line,
                                color: AppColors.accent,
                              ),
                              title: const Text('Durum Paylaş'),
                              onTap: () {},
                            ),
                          ])
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      ;
      ;
      break;
    case 3:
      context.go('/search');
      break;
    case 4:
      context.go('/myAccount');
      break;
  }
}
