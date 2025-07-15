import 'package:flutter/material.dart';
import 'package:merinocizgi/features/adminPanel/widget/dynamic_island_bar.dart';

// Bu sınıf, DynamicIslandBar'ın bir Sliver olarak nasıl davranacağını tanımlar.
class SliverDynamicBarDelegate extends SliverPersistentHeaderDelegate {
  final DynamicIslandBar dynamicIslandBar;

  SliverDynamicBarDelegate({required this.dynamicIslandBar});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // shrinkOffset, ne kadar yukarı kaydırıldığını belirtir.
    // overlapsContent, içeriğin üzerine gelip gelmediğini belirtir.
    // Bizim bar'ımız her zaman aynı görünecek, bu yüzden bu parametreleri kullanmıyoruz.
    return Container(
      // Arka plan rengi, kaydırıldığında listenin arkasında kalmasın diye önemli.
      color: Theme.of(context).scaffoldBackgroundColor,
      child: dynamicIslandBar,
    );
  }

  // Bar'ın maksimum (genişletilmiş) yüksekliği
  @override
  double get maxExtent =>
      72.0; // DynamicIslandBar'ın yaklaşık yüksekliği (Padding dahil)

  // Bar'ın minimum (daraltılmış) yüksekliği.
  // Kaybolmasını istediğimiz için 0 yapabiliriz, ama yapışmasını istiyorsak maxExtent ile aynı yaparız.
  // Bizim senaryomuzda kaybolacak, ama header'ın kendisi kaybolacak, delegate değil.
  @override
  double get minExtent => 72.0;

  // Header'ın içeriği değiştiğinde yeniden oluşturulup oluşturulmayacağı.
  // Bizim bar'ımızın içeriği dışarıdan geldiği için kontrol etmeliyiz.
  @override
  bool shouldRebuild(SliverDynamicBarDelegate oldDelegate) {
    return dynamicIslandBar.selectedIndex !=
        oldDelegate.dynamicIslandBar.selectedIndex;
  }
}
