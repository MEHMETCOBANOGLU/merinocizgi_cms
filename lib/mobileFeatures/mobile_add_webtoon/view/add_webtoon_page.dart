import 'package:flutter/material.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileAddWebtoonPage extends StatelessWidget {
  const MobileAddWebtoonPage({super.key});

  void _launchWebsite() async {
    // const url = 'https://merinocizgi.com.tr/';
    final Uri url = Uri.parse('https://merinocizgi.com.tr/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Webtoon Ekle")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.draw_rounded, size: 100, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              "Çizgi Romanını Yükle!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Çizgi romanınızı yayınlamak için masaüstü sitemizi (https://merinocizgi.com.tr) ziyaret edin. Web üzerinden giriş yaptıktan sonra ‘YAYINLA’ sekmesine tıklayıp çizgi romanınızı yükleyin.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _launchWebsite,
              icon: const Icon(Icons.open_in_browser),
              label: const Text("Siteyi Aç"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
