import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/view/screens/flash_sale/flash_sale_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/bad_weather_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/best_reviewed_item_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/store_wise_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/best_store_nearby_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/category_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/promo_code_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/item_that_you_love_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/just_for_you_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/most_popular_item_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/new_on_mart_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/middle_section_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/special_offer_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/promotional_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/visit_again_view.dart';


class GroceryHomeScreen extends StatelessWidget {
  const GroceryHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).disabledColor.withOpacity(0.1),
        child:  const Column(
          children: [
            BadWeatherWidget(),

            BannerView(isFeatured: false),
            SizedBox(height: 12),
          ],
        ),
      ),

      const CategoryView(),
      isLoggedIn ? const VisitAgainView() : const SizedBox(),
      const SpecialOfferView(isFood: false, isShop: false),
      const FlashSaleView(),
      const BestStoreNearbyView(),
      const MostPopularItemView(isFood: false, isShop: false),
      const MiddleSectionBannerView(),
      const BestReviewItemView(),
      // const StoreWiseBannerView(),
      const JustForYouView(),
      const ItemThatYouLoveView(forShop: false),
      isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
      const NewOnMartView(isPharmacy: false, isShop: false),
      const PromotionalBannerView(),
    ]);
  }
}
