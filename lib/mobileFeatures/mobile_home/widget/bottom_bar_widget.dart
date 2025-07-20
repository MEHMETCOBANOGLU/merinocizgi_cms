import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
              onPressed: () => onItemSelected(index),
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
      context.go('/search'); // Örnek bir rota
      break;
    case 3:
      context.go('/myAccount');
      break;
  }
}
