// lib/features/admin/widgets/author_search_field.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:merinocizgi/core/theme/index.dart'; // Debouncer için gerekli

class AuthorSearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const AuthorSearchField({super.key, required this.onChanged});

  @override
  State<AuthorSearchField> createState() => _AuthorSearchFieldState();
}

class _AuthorSearchFieldState extends State<AuthorSearchField> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Arama kutusundaki her değişikliği dinle.
    _searchController.addListener(_onSearchChanged);
  }

  // Kullanıcı yazmayı bıraktıktan kısa bir süre sonra arama yapmak için (performans)
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        // Widget hala ağaçtaysa
        widget.onChanged(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        // Açıldığında klavyeyi otomatik getir.
        _focusNode.requestFocus();
      } else {
        // Kapatıldığında metni temizle ve klavyeyi kapat.
        _searchController.clear();
        _focusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sabit genişlikler tanımlayalım
    const double collapsedWidth = 48.0;
    const double expandedWidth = 228.0; // 40 (ikon) + 180 (textfield)

    // TweenAnimationBuilder, iki değer arasında yumuşak bir geçiş sağlar.
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // 1. Arka plan Container'ı (Animasyonlu)
        // Bu container, arama çubuğunun arka planını ve çerçevesini oluşturur.
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
              begin: collapsedWidth,
              end: _isSearching ? expandedWidth : collapsedWidth),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, width, _) {
            return Container(
              width: width,
              height: 48.0,
              decoration: BoxDecoration(
                color: _isSearching ? Colors.white : Colors.grey[200],
                borderRadius: BorderRadius.circular(30.0),
                border:
                    _isSearching ? Border.all(color: AppColors.accent) : null,
                boxShadow: [
                  if (_isSearching)
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                ],
              ),
            );
          },
        ),

        // 2. TextField (Animasyonlu)
        // Bu, arama çubuğu açıldığında yavaşça belirecek olan metin kutusudur.
        // Padding ile ikonun kapladığı alanı boş bırakıyoruz.
        Padding(
          padding: const EdgeInsets.only(left: 48.0, right: 12.0),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: _isSearching ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
            builder: (context, opacity, _) {
              return Opacity(
                opacity: opacity,
                // TextField'ın görünürlüğünü de kontrol edelim ki kapalıyken yer kaplamasın.
                child: Visibility(
                  visible: _isSearching,
                  child: SizedBox(
                    width: 170.0, // Genişliği sabit ve sınırlı yapıyoruz
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      decoration: const InputDecoration(
                          hintText: "Yazar Ara (Email)",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          focusedBorder: InputBorder.none),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 3. Arama/Kapatma İkonu (Her zaman en üstte)
        // Bu ikon, diğer her şeyin üzerinde durur.
        Container(
          width: 48.0,
          height: 48.0,
          alignment: Alignment.center,
          child: IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: _isSearching ? AppColors.accent : Colors.grey[800],
            ),
            onPressed: _toggleSearch,
          ),
        ),
      ],
    );
  }
}
