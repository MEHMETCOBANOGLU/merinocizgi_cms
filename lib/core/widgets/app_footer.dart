import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';
import 'package:merinocizgi/core/providers/series_provider.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:merinocizgi/core/utils/responsive.dart';
import 'package:merinocizgi/core/widgets/app_button.dart';
import 'package:outlined_text/outlined_text.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends ConsumerWidget {
  const AppFooter({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = context.isTabletB;
    final auth = ref.read(authStateProvider);
    final isLoggedIn = auth is AsyncData && auth.value?.user != null;
    // final bool isPhone = context.isPhone;

    // Dinamik kartlar için provider'ları izle
    final featuredSeriesAsync = ref.watch(featuredSeriesProvider);
    // final newArtistAsync = ref.watch(newArtistProvider);

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ÜST: Uygulama Vurgusu
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 40,
            runSpacing: 32,
            children: [
              // _buildPromoText(isWideScreen),
              _buildWideLayout(isWideScreen),
            ],
          ),

          const SizedBox(height: 20),
          Text("Merino Dünyasına Adım At", style: AppTextStyles.subheading),

          const SizedBox(height: 32),
          SizedBox(
            height: 140, // Kartların yüksekliğine göre ayarla
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                // STATİK KARTLAR
                _InteractionCard(
                    icon: FontAwesomeIcons.envelopeOpenText,
                    label: 'Bize Ulaşın',
                    sublabel: 'Soru ve önerileriniz için',
                    onTap: () => _launchURL('mailto:info@merinocizgi.com.tr')),
                _InteractionCard(
                    icon: FontAwesomeIcons.instagram,
                    label: 'Instagram\'da Biz',
                    sublabel: 'Yeni çizimleri kaçırma',
                    onTap: () => _launchURL('https://instagram.com/')),
                _InteractionCard(
                    icon: FontAwesomeIcons.discord,
                    label: 'Topluluğa Katıl',
                    sublabel: 'Discord sunucumuza gel',
                    onTap: () => _launchURL('https://discord.gg/')),
                _InteractionCard(
                  icon: FontAwesomeIcons.penRuler,
                  label: 'Hikayeni Paylaş',
                  sublabel: 'Kendi çizgi romanını yayınla',
                  // onTap: () => context.go('/create-comic')),
                  onTap: () {
                    if (isLoggedIn) {
                      context.go('/create-comic');
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Center(
                              child: Text(
                            "Giriş gerekli",
                            style: AppTextStyles.title
                                .copyWith(color: Colors.black),
                          )),
                          content: const Text(
                              "Devam etmek için önce giriş yapmalısın."),
                          actions: [
                            TextButton(
                                onPressed: () => context.pop(),
                                child: const Text("Tamam"))
                          ],
                        ),
                      );
                    }
                  },
                ),
                _InteractionCard(
                    icon: FontAwesomeIcons.solidHeart,
                    label: 'Sanatı Destekle',
                    sublabel: 'Platformun büyümesine yardım et',
                    onTap: () => _launchURL('https://patreon.com/')),

                // DİNAMİK KART 1: HAFTANIN SERİSİ
                featuredSeriesAsync.when(
                  data: (doc) {
                    if (doc == null) return const SizedBox.shrink();
                    final data = doc.data() as Map<String, dynamic>;
                    return _InteractionCard(
                      imageUrl: data['squareImageUrl'],
                      label: 'Haftanın Serisi',
                      sublabel: data['title'] ?? '',
                      onTap: () => print('Tıklandı'),
                      // onTap: () => context
                      //     .go('/series/${doc.id}'), // Rota yapına göre ayarla
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => const SizedBox.shrink(),
                ),

                // DİNAMİK KART 2: YENİ SANATÇI
                // newArtistAsync.when(
                //   data: (doc) {
                //     if (doc == null) return const SizedBox.shrink();
                //     final data = doc.data() as Map<String, dynamic>;
                //     return _InteractionCard(
                //       imageUrl: data['profileImageUrl'],
                //       label: 'Aramıza Hoş Geldin!',
                //       sublabel: data['mahlas'] ?? '',
                //       onTap: () => context
                //           .go('/artist/${doc.id}'), // Rota yapına göre ayarla
                //     );
                //   },
                //   loading: () =>
                //       const Center(child: CircularProgressIndicator()),
                //   error: (e, st) => const SizedBox.shrink(),
                // ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Divider(
              color: Colors.white24, thickness: 1, indent: 40, endIndent: 40),

          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 8,
            children: [
              // Yasal linkler için de aynı şık widget'ı kullanabiliriz.
              _HoverableFooterLink(
                  label: 'Kullanım Koşulları', route: '/terms'),

              ///terms

              _HoverableFooterLink(
                  label: 'KVKK Aydınlatma Metni', route: '/kvkk'),

              ///kvkk
              _HoverableFooterLink(
                  label: 'Çerez Politikası', route: '/cookies'),

              ///cookies
            ],
          ),

          // ALT: Linkler ve Sosyal Medya
          // isWideScreen ? _buildBottomRow(context) : _buildBottomColumn(context),

          const SizedBox(height: 32),
          Text(
            '© ${DateTime.now().year} MerinoÇizgi • Tüm hakları saklıdır',
          ),
        ],
      ),
    );
  }

  Widget _buildPromoText(bool isWideScreen) {
    return SizedBox(
      width: isWideScreen ? 600 : double.infinity,
      child: Column(
        crossAxisAlignment: isWideScreen
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.center,
        children: [
          Text(
            'ŞİMDİ KEŞFETMEYE BAŞLA!',
            style: AppTextStyles.heading.copyWith(
              color: Colors.black,
              fontSize: isWideScreen ? 28 : 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'MERİNO MOBİL UYGULAMASİYLA ÇİZGİ ROMAN DÜNYASINI CEBİNE TAŞI.',
            style: AppTextStyles.subheading
                .copyWith(fontSize: 20, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(bool isWideScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color: Colors.grey,
        color: AppColors.accent.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      // --- ANA DEĞİŞİKLİK: Row YERİNE Flex ---
      child: Flex(
        // 'isWideScreen' durumuna göre yönü belirle.
        direction: isWideScreen ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SOL (veya ÜST): METİN + BUTON
          SizedBox(
            // Genişliği dar ekranda esnek hale getirelim.
            // Geniş ekranda sabit 500, dar ekranda ise daha küçük bir değer olabilir
            // veya null bırakarak Column'un genişliğine uymasını sağlayabiliriz.
            // Şimdilik null bırakmak en güvenlisi.
            width: isWideScreen ? 500 : null,
            child: Column(
              // Dar ekranda metinleri ve butonları ortala.
              crossAxisAlignment: isWideScreen
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedText(
                      text: Text(
                        'MERİNO',
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      strokes: [
                        OutlinedTextStroke(color: Colors.black, width: 6)
                      ],
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    OutlinedText(
                      text: Text(
                        'ÇİZGİ',
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      strokes: [
                        OutlinedTextStroke(color: Colors.black, width: 6)
                      ],
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    if (isWideScreen)
                      Text('YAYINDA!', style: AppTextStyles.heading),
                  ],
                ),
                if (!isWideScreen) const SizedBox(height: 12),
                if (!isWideScreen)
                  Center(child: Text('YAYINDA!', style: AppTextStyles.heading)),

                const SizedBox(height: 12),
                Text(
                  'Uygulamayı indir, en güncel çizgi romanları her yerde oku.',
                  style: AppTextStyles.subheading,
                  textAlign: isWideScreen ? TextAlign.left : TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Butonları dar ekranda da yan yana tutmak için Row içinde bırakıyoruz.
                // Eğer alt alta gelmelerini istersen bu Row'u da bir Flex'e çevirebiliriz.
                // --- ÇÖZÜM BURADA: Expanded KALDIRILDI ---
                //               // _buildTextButtons zaten bir Column ve kendi yüksekliğine sahip.
                //               // Onu genişletmeye çalışmak hataya neden oluyordu.
                //               // Şimdi sadece olduğu gibi çiziyoruz.
                _buildTextButtons(isWideScreen),
              ],
            ),
          ),

          // Geniş ekranda yatay, dar ekranda dikey boşluk.
          isWideScreen ? const SizedBox.shrink() : const SizedBox(height: 40),

          // ORTA: TELEFON FRAME
          SizedBox(
            width: isWideScreen ? 300 : 200,
            height: isWideScreen ? 300 : 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/images/frame.png', fit: BoxFit.contain),
              ],
            ),
          ),

          isWideScreen ? const SizedBox.shrink() : const SizedBox(height: 40),

          // SAĞ (veya ALT): LOGO
          Image.asset('assets/images/merino.png',
              width: isWideScreen ? 300 : 200, fit: BoxFit.contain),
        ],
      ),
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

  Widget _buildTextButtons(bool isWide) {
    const buttonWidth = 200.0; // Maksimum buton genişliği

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: buttonWidth),
                  child: _storeButton(Icons.apple, 'App Store\'dan\nİndir'),
                ),
                const SizedBox(width: 24),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: buttonWidth),
                  child: _storeButton(null, 'Google Play\'den\nİndir',
                      asset: 'googlePlay.png'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: buttonWidth),
                  child: _storeButton(Icons.apple, 'App Store\'dan\nİndir'),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: buttonWidth),
                  child: _storeButton(null, 'Google Play\'den\nİndir',
                      asset: 'googlePlay.png'),
                ),
              ],
            ),
    );
  }
}

// lib/core/widgets/app_footer.dart dosyasının en altına ekle

class _HoverableFooterLink extends StatefulWidget {
  final String label;
  final String route;

  const _HoverableFooterLink({
    super.key,
    required this.label,
    required this.route,
  });

  @override
  State<_HoverableFooterLink> createState() => _HoverableFooterLinkState();
}

class _HoverableFooterLinkState extends State<_HoverableFooterLink> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = context.isTabletB;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        // onTap: () => context.go(widget.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0), // Dikey boşluk
          child: Row(
            mainAxisSize: MainAxisSize.min, // Sadece içeriği kadar yer kapla
            children: [
              // Hover durumuna göre beliren ok ikonu
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isHovering ? 1.0 : 0.0,
                // child: const Icon(Icons.arrow_forward_ios,
                //     color: Colors.white, size: 12),
              ),

              // İkon ve metin arasına animasyonlu boşluk
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isHovering ? 8.0 : 0.0,
              ),

              // Link metni
              Text(
                widget.label,
                style: AppTextStyles.text.copyWith(
                    // Hover durumuna göre rengi değiştir
                    color: _isHovering ? Colors.black : Colors.black87,
                    fontSize: (widget.route == '/cookies' ||
                            widget.route == '/kvkk' ||
                            widget.route == '/terms')
                        ? 16
                        : 25,
                    decoration: (widget.route == '/cookies' ||
                            widget.route == '/kvkk' ||
                            widget.route == '/terms')
                        ? TextDecoration.underline
                        : null,
                    decorationColor: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- YENİ YARDIMCI WIDGET ---
Widget _buildContactStrip() {
  return SizedBox(
    height: 120, // Film şeridi için sabit bir yükseklik
    child: ListView(
      scrollDirection: Axis.horizontal, // YATAY KAYDIRMA
      shrinkWrap:
          true, // İçeriğe göre boyutlanmasını sağlar (Column içinde önemli)
      children: [
        const SizedBox(width: 24), // Başlangıç boşluğu
        _ContactCard(
          icon: FontAwesomeIcons.envelope,
          label: 'E-Posta Gönder',
          sublabel: 'mehmett_ceng@hotmail.com',
          onTap: () => _launchURL(
              'mailto:mehmett_ceng@hotmail.com?subject=MerinoÇizgi%20Hakkında'),
        ),
        _ContactCard(
          icon: FontAwesomeIcons.instagram,
          label: 'Instagram',
          sublabel: '@mehmet_cbnoglu',
          onTap: () => _launchURL('https://instagram.com/mehmet_cbnoglu'),
        ),
        _ContactCard(
          icon: FontAwesomeIcons.linkedin,
          label: 'LinkedIn',
          sublabel: 'Mehmet Çobanoğlu',
          onTap: () =>
              _launchURL('https://linkedin.com/in/mehmet-çobanoğlu-206747245'),
        ),
        _ContactCard(
          icon: FontAwesomeIcons.github,
          label: 'GitHub',
          sublabel: 'Projelerimi İncele',
          onTap: () => _launchURL('https://github.com/MEHMETCOBANOGLU'),
        ),
        const SizedBox(width: 24), // Bitiş boşluğu
      ],
    ),
  );
}

// URL açmak için yardımcı metot
void _launchURL(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    // Hata yönetimi eklenebilir.
    print('Could not launch $url');
  }
}

// lib/core/widgets/app_footer.dart dosyasının en altına ekle

class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _ContactCard({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  State<_ContactCard> createState() => __ContactCardState();
}

class __ContactCardState extends State<_ContactCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 220,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: _isHovering
                ? Colors.white.withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: _isHovering
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(widget.icon, color: Colors.white, size: 28),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.sublabel,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/core/widgets/app_footer.dart dosyasının en altına ekle

class _InteractionCard extends StatefulWidget {
  final IconData? icon;
  final String? imageUrl; // Görsel odaklı kartlar için
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _InteractionCard({
    super.key,
    this.icon,
    this.imageUrl,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  State<_InteractionCard> createState() => _InteractionCardState();
}

class _InteractionCardState extends State<_InteractionCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 220,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: _isHovering ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: _isHovering
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
            ),
            boxShadow: [
              if (_isHovering)
                const BoxShadow(
                  color: Colors.white54,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // İkon veya Resim gösterme
              if (widget.imageUrl != null)
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(widget.imageUrl!),
                )
              else if (widget.icon != null)
                FaIcon(widget.icon, color: Colors.white, size: 28),

              const SizedBox(height: 12),
              Text(
                widget.label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.sublabel,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
