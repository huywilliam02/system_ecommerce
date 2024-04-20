import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/bad_weather_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/basic_medicine_nearby_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/best_store_nearby_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/common_condition_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/just_for_you_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/middle_section_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/new_on_mart_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/promotional_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/visit_again_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/category_view.dart';

class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({Key? key}) : super(key: key);

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
      const ProductWithCategoriesView(),
      const MiddleSectionBannerView(),
      const BestStoreNearbyView(),
      const JustForYouView(),
      const NewOnMartView(isShop: false, isPharmacy: true, isNewStore: true),
      const CommonConditionView(),
      const PromotionalBannerView(),

    ]);
  }
}
