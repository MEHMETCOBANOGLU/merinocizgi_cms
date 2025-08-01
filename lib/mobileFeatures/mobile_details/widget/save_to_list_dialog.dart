import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/mobileFeatures/mobile_details/controller/library_controller.dart';

class SaveToListDialog extends ConsumerStatefulWidget {
  final String seriesId;
  final bool isBook;
  const SaveToListDialog({required this.seriesId, required this.isBook});

  // State'i oluşturan satır doğru.
  @override
  ConsumerState<SaveToListDialog> createState() => SaveToListDialogState();
}

class SaveToListDialogState extends ConsumerState<SaveToListDialog> {
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

    ref.read(libraryControllerProvider.notifier).addContentToLibraries(
          contentId: widget.seriesId,
          libraryIds: _selectedLibraryIds.toList(),
          contentType: widget.isBook ? 'books' : 'series',
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
