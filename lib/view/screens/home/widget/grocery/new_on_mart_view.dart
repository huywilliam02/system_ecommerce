import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/card_design/store_card.dart';
import 'package:citgroupvn_ecommerce/view/base/card_design/store_card_with_distance.dart';
import 'package:citgroupvn_ecommerce/view/base/rating_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_new_on_view.dart';

class NewOnMartView extends StatelessWidget {
  final bool isPharmacy;
  final bool isShop;
  final bool isNewStore;
  const NewOnMartView({Key? key, required this.isPharmacy, required this.isShop, this.isNewStore = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store>? storeList = /*(isNewStore || isPharmacy || isShop) ?*/ storeController.latestStoreList/* : storeController.popularStoreList*/;

      return storeList != null ? storeList.isNotEmpty ? Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: TitleWidget(
              title: '${'new_on'.tr} ${AppConstants.appName}',
              onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute('latest')),
            ),
          ),
          // const SizedBox(height: Dimensions.paddingSizeSmall),

          (isPharmacy || isShop) ? SizedBox(
            height: 215,
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                itemCount: storeList.length,
                itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                    child: StoreCardWithDistance(store: storeList[index], isNewStore: isNewStore),
                  );
                }),
          ) : SizedBox(
            height: 140,
            child: ListView.builder(
              controller: ScrollController(),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              itemCount: storeList.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
                  child: StoreCard(store: storeList[index], isNewStore: isNewStore),
                );
              },
            ),
          ),
        ]),
      ) : const SizedBox.shrink() : const WebNewOnShimmerView();
    });
  }
}

class PopularStoreShimmer extends StatelessWidget {
  final StoreController storeController;
  const PopularStoreShimmer({Key? key, required this.storeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        itemCount: 10,
        itemBuilder: (context, index){
          return Container(
            height: 150, width: 200,
            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 10, spreadRadius: 1)],
            ),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Container(
                  height: 90, width: 200,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                      color: Colors.grey[300],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                      Container(height: 10, width: 100, color: Colors.grey[300]),
                      const SizedBox(height: 5),

                      Container(height: 10, width: 130, color: Colors.grey[300]),
                      const SizedBox(height: 5),

                      const RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                    ]),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

