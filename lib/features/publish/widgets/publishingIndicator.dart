import 'dart:ui';
import 'package:flutter/material.dart';

// Bu fonksiyon artık sadece yeni stateful widget'ı gösterir.
void showPublishingDialog(BuildContext context, Future<void> publishingFuture) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return _PublishingDialog(publishingFuture: publishingFuture);
    },
  );
}

// Diyaloğun kendisi artık stateful ve kendi yaşam döngüsünü yönetiyor.
class _PublishingDialog extends StatefulWidget {
  final Future<void> publishingFuture;

  const _PublishingDialog({super.key, required this.publishingFuture});

  @override
  State<_PublishingDialog> createState() => _PublishingDialogState();
}

class _PublishingDialogState extends State<_PublishingDialog> {
  @override
  void initState() {
    super.initState();
    // Widget oluşturulduğunda, kendisine verilen Future'ı dinlemeye başla.
    widget.publishingFuture.whenComplete(() {
      // Future tamamlandığında (başarılı veya başarısız),
      // bu widget hala ekrandaysa, kendi kendini kapat.
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Diyalogun UI'ı aynı kalıyor.
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(color: Colors.black.withOpacity(0.1)),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            width: 300,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Çizgi romanınız yayınlanıyor...',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black), // AppTextStyles yerine
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                LinearProgressIndicator(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
