import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/index.dart';
import 'package:merinocizgi/core/utils/responsive.dart';
import 'package:merinocizgi/features/adminPanel/widget/make_admin.dart';
import 'author_search_field.dart';

class DynamicIslandBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<String> onSearchChanged;

  const DynamicIslandBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive kontrolünü burada yapıyoruz.
    final bool isWideScreen = context.isTablet;

    // Eğer geniş ekran ise, elemanları yan yana (Row) diz.
    if (isWideScreen) {
      return _buildWideLayout(context);
    }
    // Değilse (dar ekran ise), elemanları alt alta (Column) diz.
    else {
      return _buildNarrowLayout(context);
    }
  }

  // --- DAR EKRANLAR İÇİN LAYOUT (Column) ---
  // (Telefon gibi dar ekranlarda elemanlar alt alta gelir)
  Widget _buildNarrowLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      child: Column(
        children: [
          // Üst satır: Sadece sekmeler
          Container(
            // width: 400, // Dar ekranda genişlik tüm alanı kaplamalı
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildTabButton("Onay Bekleyenler", 0),
                _buildTabButton("Tüm Seriler", 1),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          // Alt satır: Arama ve Admin Ekle butonu
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Arama çubuğunu esnek yapalım ki alana sığsın
              Expanded(child: AuthorSearchField(onChanged: onSearchChanged)),
              const SizedBox(width: 12.0),
              // Admin ekle butonu
              Container(
                height: 48.0,
                width: 48.0,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: "Yeni Admin Ata",
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  onPressed: () => showDialog(
                      context: context, builder: (_) => const MakeAdminPopUp()),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // --- GENİŞ EKRANLAR İÇİN LAYOUT (Row) ---
  // (Tablet ve masaüstü gibi geniş ekranlarda elemanlar yan yana gelir)
  Widget _buildWideLayout(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sol taraf: Sekmeler
          Container(
            width: screenW *
                0.3, // Sabit bir genişlik vererek daha düzenli durmasını sağlayalım
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                _buildTabButton("Onay Bekleyenler", 0),
                _buildTabButton("Tüm Seriler", 1)
              ],
            ),
          ),
          const SizedBox(width: 26),
          // Orta: Arama Çubuğu
          AuthorSearchField(onChanged: onSearchChanged),
          // Sağ tarafı boşlukla it
          const SizedBox(width: 8),
          // En Sağ: Admin ekle butonu
          Container(
            height: 48.0,
            width: 48.0,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: "Yeni Admin Ata",
              icon: const Icon(Icons.person_add_alt_1_outlined),
              onPressed: () => showDialog(
                  context: context, builder: (_) => const MakeAdminPopUp()),
            ),
          )
        ],
      ),
    );
  }

  // Bu metot hem dar hem de geniş ekran düzeni tarafından kullanılır.
  Widget _buildTabButton(String label, int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
