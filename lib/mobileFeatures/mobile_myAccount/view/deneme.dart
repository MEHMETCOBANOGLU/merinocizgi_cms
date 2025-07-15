//  bottomNavigationBar: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
//             child: BottomBarWidget(
//               items: [
//                 BottomBarItem(
//                   icon: Icons.home_outlined,
//                   color: selectedBottomBarIndex == 0
//                       ? AppColors.primary
//                       : Colors.white,
//                   onTap: () {
//                     ref.read(selectedBottomBarIndexProvider.notifier).state = 0;
//                 context.go('/');
//                   },
//                 ),
//                 BottomBarItem(
//                   icon: Icons.favorite_border,
//                   color: selectedBottomBarIndex == 1
//                       ? AppColors.primary
//                       : Colors.white,
//                   onTap: () {
//                     ref.read(selectedBottomBarIndexProvider.notifier).state = 1;
//                   },
//                 ),
//                 BottomBarItem(
//                   icon: Icons.search_outlined,
//                   color: selectedBottomBarIndex == 2
//                       ? AppColors.primary
//                       : Colors.white,
//                   onTap: () {
//                     ref.read(selectedBottomBarIndexProvider.notifier).state = 2;
//                   },
//                 ),
//                 BottomBarItem(
//                   icon: Icons.person_outlined,
//                   color: selectedBottomBarIndex == 3
//                       ? AppColors.primary
//                       : Colors.white,
//                   onTap: () {
//                     ref.read(selectedBottomBarIndexProvider.notifier).state = 3;
//                     context.push('/myAccount');
//                   },
//                 ),
//               ],
//             )));
//   }
