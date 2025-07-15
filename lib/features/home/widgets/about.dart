import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merinocizgi/core/theme/breakpoints.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/core/widgets/app_button.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      color: AppColors.primary,
      width: double.infinity,
      // Minimum yükseklik
      constraints: BoxConstraints(minHeight: screenSize.height * 0.8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppBreakpoints.tablet;

          // Ortak çocukları tek listede tutuyoruz:
          final children = <Widget>[
            // 1) Resim bloğu
            // isWide ise Expanded, değilse doğal boyut
            isWide
                ? Expanded(
                    child: _buildImage(screenSize, isWide),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _buildImage(screenSize, isWide),
                  ),

            // 2) Metin & Buton bloğu
            isWide
                ? Expanded(
                    child: _buildTextButtons(screenSize, isWide),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTextButtons(screenSize, isWide),
                  ),
          ];

          return isWide
              ? Row(children: children)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                );
        },
      ),
    );
  }

  Widget _buildImage(Size screenSize, bool isWide) {
    return Center(
      child: Transform.rotate(
        angle: isWide ? -0.1 : 0,
        child: Image.asset(
          'assets/images/mobile2.png',
          width: isWide ? screenSize.width * 0.4 : screenSize.width * 0.7,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTextButtons(Size screenSize, bool isWide) {
    return Column(
      mainAxisAlignment:
          isWide ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Center(
          child: Semantics(
            header: true, // Bunun bir başlık olduğunu belirtir.
            headingLevel: 1,
            child: Text(
              'MERINO ÇİZGİ YAYINDA!',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Semantics(
            header: true,
            child: Semantics(
              header: true,
              headingLevel: 1,
              child: Text(
                'EN YENİ ÇİZGİ ROMANLARI\nMERİNO İLE KEŞFET',
                textAlign: TextAlign.center,
                style: AppTextStyles.subheading,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Semantics(
              header: true,
              headingLevel: 2,
              child: Text(
                'MERİNO ile çizgi romanın sınırlarını zorla: karanlık fantezi evrenlerinden sıcak dostluk hikâyelerine, '
                'destansı kahramanlık öykülerinden kalbine dokunan gündelik kesitlere kadar yüzlerce farklı dünyayı keşfet. '
                'Favori çizerlerinin en taze bölümlerini tek tıkla oku, beğen ve yorum yap; hatta kendi çizgi romanını yayımlayarak '
                'topluluğun bir parçası ol.',
                // textAlign: isWide ? TextAlign.left : TextAlign.center,
                style: AppTextStyles.text,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
          child: Row(
            // mainAxisAlignment:
            // isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: _storeButton(
                        Icons.apple, 'App Store\'dan\n        İndir'),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: _storeButton(
                        null, 'Google Play\'dan\n          İndir',
                        asset: 'googlePlay.png'),
                  ),
                ],
              ),
              Image.asset(
                'assets/images/qr.png',
                width: isWide ? screenSize.width * 0.2 : screenSize.width * 0.4,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _storeButton(IconData? icon, String label, {String? asset}) {
    return AppButton(
      label: label,
      icon: icon,
      asset: asset,
      onPressed: () {},
    );
  }
}
