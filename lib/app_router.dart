// lib/app_router.dart

import 'package:flutter/foundation.dart' show kIsWeb; // kIsWeb kontrolü için
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merinocizgi/core/providers/auth_state_provider.dart';

// Ortak Layout Widget'ları
import 'package:merinocizgi/core/widgets/main_layout.dart';
import 'package:merinocizgi/features/legal/view/cookie_policy_page.dart';
import 'package:merinocizgi/features/legal/view/kvkk_page.dart';
import 'package:merinocizgi/features/legal/view/terms_of_service_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_add_webtoon/view/add_webtoon_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_auth/view/loginPage.dart';
import 'package:merinocizgi/mobileFeatures/mobile_auth/widgets/email_login_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/book_chapters_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/create_book_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_books/view/edit_chapter_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/view/bookDetailsPage.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/view/myAccountPage.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/accountSettings.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/followers_list_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/following_list_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_myAccount/widget/reading_list_widget.dart';
import 'package:merinocizgi/mobileFeatures/mobile_reader/view/book_reader_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_search/view/search_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_user_profile/view/userProfilePage.dart';
import 'package:merinocizgi/mobileFeatures/shared/view/mobile_main_layout.dart'; // Mobil için yeni layout

// Web Sayfaları
import 'package:merinocizgi/features/home/view/homePage.dart';
import 'package:merinocizgi/features/publish/view/create_comic_flow_page.dart';
import 'package:merinocizgi/features/account/view/myAccountPages.dart';
import 'package:merinocizgi/features/adminPanel/view/admin_dashboard_page.dart';

// Mobil Sayfaları (Bunları oluşturman gerekecek)
import 'package:merinocizgi/mobileFeatures/mobile_home/view/homePage.dart';
import 'package:merinocizgi/mobileFeatures/mobile_library/view/libraryPage.dart';
import 'package:merinocizgi/mobileFeatures/mobile_reader/view/comic_reader_page.dart';
import 'package:merinocizgi/mobileFeatures/mobile_comic_details/view/comicDetailsPage.dart';

///router provider
/// GoRouter örneğini oluşturur ve state değişikliklerine göre yönlendirmeyi yönetir.
final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    // `refreshListenable`, yönlendirmenin ne zaman yeniden değerlendirileceğini belirler.
    // Artık bu, bizim kontrolümüzdeki `routerNotifier`'a bağlı.
    refreshListenable: routerNotifier,

    // `redirect`, yönlendirme mantığını içerir.
    // Bu mantık artık Notifier'ın içindeki senkronize değerlere göre çalışır.
    redirect: routerNotifier.redirect,

    // --- PLATFORMA GÖRE ROTA SEÇİMİ ---
    // kIsWeb sabiti, kodun web'de mi yoksa mobilde mi çalıştığını belirtir.
    routes: kIsWeb ? _getWebRoutes() : _getMobileRoutes(),

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Sayfa Bulunamadı')),
      body: Center(child: Text('Aradığınız sayfa bulunamadı: ${state.error}')),
    ),
  );
});

// --- WEB PLATFORMU İÇİN ROTA LİSTESİ ---
List<RouteBase> _getWebRoutes() {
  return [
    // ---ShellRoute ---
    // Bu rota, altındaki tüm rotalar için bir kabuk (UI shell) görevi görür.
    ShellRoute(
      // 'builder', kabuk widget'ını oluşturur. 'child' parametresi,
      // o anki aktif alt rotanın widget'ıdır (HomePage, PublishPage vs.).
      builder: (context, state, child) => MainLayout(child: child),
      // 'routes', bu kabuğu kullanacak olan sayfa rotalarını içerir.
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
            path: '/create-comic',
            builder: (context, state) => const CreateComicFlowPage()),
        GoRoute(
            path: '/account',
            builder: (context, state) => const Myaccountpages()),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const TermsOfServicePage(),
        ),
        // GoRoute(
        //   path: '/privacy',
        //   builder: (context, state) => const PrivacyPolicyPage(),
        // ),
        GoRoute(
          path: '/kvkk',
          builder: (context, state) => const KvkkPage(),
        ),
        GoRoute(
          path: '/cookies',
          builder: (context, state) => const CookiePolicyPage(),
        ),
      ],
    ),
    // Admin paneli gibi kabuk dışında kalacak sayfalar
    // GoRoute(
    //   path: '/admin',
    //   builder: (context, state) => const AdminDashboardPage(),
    // ),
    // Web için seri detay sayfası
    // GoRoute(
    //     path: '/series/:seriesId',
    //     builder: (context, state) {
    //       final seriesId = state.pathParameters['seriesId']!;
    //       // Web'de seri detay sayfanız varsa buraya onun widget'ını koyun
    //       return WebSeriesDetailPage(seriesId: seriesId);
    //     }),
  ];
}

// --- MOBİL PLATFORMLAR İÇİN ROTA LİSTESİ ---
List<RouteBase> _getMobileRoutes() {
  return [
    // Mobil için ana kabuk (BottomNavigationBar'lı layout)
    ShellRoute(
      builder: (context, state, child) => MobileMainLayout(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const MobileHomePage()),
        GoRoute(
            path: '/library',
            builder: (context, state) => const MobileLibraryPage()),
        GoRoute(
          path: '/myAccount',
          builder: (context, state) => const MyAccountPage(),
          routes: [
            // BookChaptersPage'in bir alt rotası olarak
            GoRoute(
              path: 'chapters/:chapterId/edit', // Düzenleme için
              builder: (context, state) {
                final bookId = state.pathParameters['bookId']!;
                final chapterId = state.pathParameters['chapterId']!;
                return EditChapterPage(bookId: bookId, chapterId: chapterId);
              },
            ),
            GoRoute(
              path: 'chapters/new', // Yeni bölüm için
              builder: (context, state) {
                final bookId = state.pathParameters['bookId']!;
                return EditChapterPage(bookId: bookId); // chapterId null olacak
              },
            ),
            GoRoute(
                path: '/search',
                builder: (context, state) => const MobileSearchPage()),
            GoRoute(
                path: '/more',
                builder: (context, state) => const MobileLibraryPage()),
          ],
        ),
        GoRoute(
            path: '/search',
            builder: (context, state) => const MobileSearchPage()),
        GoRoute(
            path: '/more',
            builder: (context, state) => const MobileLibraryPage()),
      ],
    ),
    // Okuma ekranı gibi tam ekran olacak, kabuk dışında kalacak sayfalar
    GoRoute(
      path: '/comic-reader/:seriesId/:episodeId',
      builder: (context, state) {
        final seriesId = state.pathParameters['seriesId']!;
        final episodeId = state.pathParameters['episodeId']!;
        return ComicReaderPage(seriesId: seriesId, episodeId: episodeId);
      },
    ),
    GoRoute(
      path: '/book-reader/:bookId/:chapterId',
      builder: (context, state) {
        final bookId = state.pathParameters['bookId']!;
        final chapterId = state.pathParameters['chapterId']!;
        return BookReaderPage(bookId: bookId, chapterId: chapterId);
      },
    ),
    GoRoute(
        path: '/detail/:seriesOrBookId',
        builder: (context, state) {
          final seriesOrBookId = state.pathParameters['seriesOrBookId']!;
          return MobileComicDetailsPage(
            seriesOrBookId: seriesOrBookId,
          );
        }),
    GoRoute(
        path: '/book-detail/:seriesOrBookId',
        builder: (context, state) {
          final seriesOrBookId = state.pathParameters['seriesOrBookId']!;
          return MobileBookDetailsPage(
            seriesOrBookId: seriesOrBookId,
          );
        }),
    GoRoute(
        path: '/myAccount',
        builder: (context, state) {
          return const MyAccountPage();
        }),
    GoRoute(
        path: '/mobileLogin',
        builder: (context, state) {
          return const MobileLoginPage();
        }),
    GoRoute(
        path: '/emailLogin',
        builder: (context, state) {
          // final seriesId = state.pathParameters['seriesId']!;
          return const EmailLoginPage(isLoginMode: true);
        }),
    GoRoute(
        path: '/UserProfile/:authorId',
        builder: (context, state) {
          final authorId = state.pathParameters['authorId']!;
          return UserProfilePage(authorId: authorId);
        }),
    GoRoute(
        path: '/followers/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return FollowersListWidget(userId: userId);
        }),
    GoRoute(
        path: '/following/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return FollowingListWidget(userId: userId);
        }),
    GoRoute(
        path: '/readingList',
        builder: (context, state) {
          return const MyReadingListPage();
        }),

    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsOfServicePage(),
    ),
    // GoRoute(
    //   path: '/privacy',
    //   builder: (context, state) => const PrivacyPolicyPage(),
    // ),
    GoRoute(
      path: '/kvkk',
      builder: (context, state) => const KvkkPage(),
    ),
    GoRoute(
      path: '/cookies',
      builder: (context, state) => const CookiePolicyPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const AccountSettingsPage(),
    ),
    GoRoute(
      path: '/addWebtoon',
      builder: (context, state) => const MobileAddWebtoonPage(),
    ),
    GoRoute(
      path: '/create-book',
      builder: (context, state) => const CreateBookPage(),
    ),

    GoRoute(
        path: '/myAccount/books/:bookId/chapters',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return BookChaptersPage(bookId: bookId);
        },
        // --- YENİ ALT ROTALAR ---
        routes: [
          // Yeni bir bölüm oluşturmak için: /account/books/{id}/chapters/new
          GoRoute(
            path: 'new',
            builder: (context, state) {
              final bookId = state.pathParameters['bookId']!;
              return EditChapterPage(bookId: bookId);
            },
          ),
          // Mevcut bir bölümü düzenlemek için: /account/books/{id}/chapters/{chapterId}/edit
          GoRoute(
            path: ':chapterId/edit',
            builder: (context, state) {
              final bookId = state.pathParameters['bookId']!;
              final chapterId = state.pathParameters['chapterId']!;
              return EditChapterPage(bookId: bookId, chapterId: chapterId);
            },
          ),
        ])
  ];
}

// --- GO_ROUTER VE RIVERPOD'I SENKRONİZE EDEN YAPI ---

/// GoRouter'ın durumunu yönetmek için özel bir Notifier.
/// Bu sınıf, Riverpod'daki auth state değişikliklerini dinler ve GoRouter'ı uyarır.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  AsyncValue<AuthState> _authState;

  RouterNotifier(this._ref) : _authState = _ref.read(authStateProvider) {
    _ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      _authState = next;
      notifyListeners();
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authStateValue = _authState;
    if (authStateValue is AsyncLoading) return null;

    final isLoggedIn =
        authStateValue.hasValue && authStateValue.value!.user != null;
    final isAdmin = isLoggedIn && authStateValue.value!.isAdmin;
    final location = state.uri.toString();

    // Korumalı yollar (hem web hem mobil için)
    final protectedRoutes = [
      '/account',
      '/create-comic',
      '/admin',
      '/profile',
      '/library'
    ];

    // Giriş yapmamışsa ve korumalı bir sayfaya gitmeye çalışıyorsa
    if (!isLoggedIn &&
        protectedRoutes.any((route) => location.startsWith(route))) {
      return '/';
    }

    // Admin değilse ve admin sayfasına gitmeye çalışıyorsa
    if (isLoggedIn && !isAdmin && location.startsWith('/admin')) {
      return '/';
    }

    // Mobilde giriş yapmışsa ve ana sayfaya gitmeye çalışıyorsa
    // if (!kIsWeb && isLoggedIn && location == '/') {
    //   return '/myAccount';
    // }

    return null;
  }
}

/// RouterNotifier'ı uygulama genelinde kullanılabilir hale getiren provider.
final routerNotifierProvider = ChangeNotifierProvider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});
