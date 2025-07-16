import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';

class DropzoneW extends StatefulWidget {
  final void Function(List<Uint8List>) onFilesChanged;

  const DropzoneW({super.key, required this.onFilesChanged});

  @override
  State<DropzoneW> createState() => _DropzoneWState();
}

class _DropzoneWState extends State<DropzoneW> {
  DropzoneViewController? _dzController;
  final List<Uint8List> _pages = [];
  Uint8List? _episodeImage;
  Future<void> _pickFiles() async {
    // Dosya seçme (web de de çalışır)
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );
    if (res == null) return;
    setState(() {
      _pages
          .addAll(res.files.where((f) => f.bytes != null).map((f) => f.bytes!));
    });
    widget.onFilesChanged(_pages);
  }

  void _removeImage(int idx) {
    setState(() {
      _pages.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(kIsWeb, 'PublishComics yalnızca web ortamında çalışır.');
    final widthH = MediaQuery.of(context).size.width;
    final heightH = MediaQuery.of(context).size.height;

    return SizedBox(
      width: widthH * 0.7,
      // padding: const EdgeInsets.all(16.0),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey.shade300),
      //   borderRadius: BorderRadius.circular(8),
      //   color: Colors.white,
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Sayfa Yükle',
                  style: AppTextStyles.title.copyWith(color: Colors.black)),
              const SizedBox(width: 8),
              Tooltip(
                message:
                    'Görselin genişliği 800 pikselden, uzunluğu 1280 pikselden az olmalıdır. Toplamda 20MB\'a kadar ve en az 5 sayfa yükleyebilirsiniz. Her bir dosya en fazla 2MB olabilir. Sadece .JPG formatına izin verilir',
                waitDuration: const Duration(milliseconds: 500),
                showDuration: const Duration(seconds: 2),
                textStyle: const TextStyle(color: Colors.white),
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: heightH * 0.4,
            child: Stack(
              children: [
                DropzoneView(
                  operation: DragOperation.copy,
                  cursor: CursorType.grab,
                  onCreated: (ctrl) => _dzController = ctrl,
                  onLoaded: () => debugPrint('Zone loaded'),
                  onError: (e) => debugPrint('Error: $e'),
                  onDropFiles: (files) async {
                    for (final file in files!) {
                      try {
                        final bytes = await _dzController!.getFileData(file);
                        setState(() => _pages.add(bytes));
                        widget.onFilesChanged(_pages);
                      } catch (e, st) {
                        debugPrint('onDropFiles exception: $e\n$st');
                      }
                    }
                  },
                ),
                // Eğer hiç sayfa yoksa "Sürükle & Bırak..." overlay'i göster
                if (_pages.isEmpty)
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sürükle & Bırak\nveya\nButona tıklayarak seç',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _pickFiles,
                            child: Container(
                              height: 60,
                              width: 60,
                              color: Colors.transparent,
                              child: Icon(Icons.cloud_upload_outlined,
                                  size: 50, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Eğer en az bir sayfa varsa, GridView içinde göster.
                if (_pages.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _pages.length,
                      itemBuilder: (_, i) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _pages[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                onTap: () => _removeImage(i),
                                child: const Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
