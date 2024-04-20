import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/wishlist_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/module_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/discount_tag.dart';
import 'package:citgroupvn_ecommerce/view/base/hover/on_hover.dart';
import 'package:citgroupvn_ecommerce/view/base/not_available_widget.dart';
import 'package:citgroupvn_ecommerce/view/base/rating_bar.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/store_screen.dart';
class WebStoreWidget extends StatelessWidget {
  final Store? store;
  const WebStoreWidget({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? discount = store!.discount != null ? store!.discount!.discount : 0;
    String? discountType = store!.discount != null ? store!.discount!.discountType : 'percent';
    bool isAvailable = store!.open == 1 && store!.active!;
    return OnHover(
      isItem: true,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              if(store != null) {
                if(Get.find<SplashController>().moduleList != null) {
                  for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                    if(module.id == store!.moduleId) {
                      Get.find<SplashController>().setModule(module);
                      break;
                    }
                  }
                }
                Get.toNamed(
                  RouteHelper.getStoreRoute(id: store!.id, page: 'item'),
                  arguments: StoreScreen(store: store, fromModule: false),
                );
              }
            },
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: Container(
              width: 500,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
                // boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
              ),
              padding: const EdgeInsets.all(1),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                Stack(children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                    child: CustomImage(
                      image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}'
                          '/${store!.coverPhoto}',
                      height: 120, width: 500, fit: BoxFit.cover,
                    ),
                  ),
                  DiscountTag(
                    discount: discount, discountType: discountType,
                    freeDelivery: store!.freeDelivery,
                  ),
                  isAvailable ? const SizedBox() : NotAvailableWidget(isStore: true, fontSize: Dimensions.fontSizeExtraSmall, isAllSideRound: false),
                  Positioned(
                    top: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall,
                    child: GetBuilder<WishListController>(builder: (wishController) {
                      bool isWished = wishController.wishStoreIdList.contains(store!.id);
                      return InkWell(
                        onTap: () {
                          if(Get.find<AuthController>().isLoggedIn()) {
                            isWished ? wishController.removeFromWishList(store!.id, true)
                                : wishController.addToWishList(null, store!, true);
                          }else {
                            showCustomSnackBar('you_are_not_logged_in'.tr);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Icon(
                            isWished ? Icons.favorite : Icons.favorite_border,  size: 20,
                            color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                          ),
                        ),
                      );
                    }),
                  ),
                ]),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        store!.name!,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text(
                        store!.address!,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      RatingBar(
                        rating: store!.avgRating,
                        ratingCount: store!.ratingCount,
                        size: 15,
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
class WebStoreShimmer extends StatelessWidget {
  const WebStoreShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: 500,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)]
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            height: 120, width: 500,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                color: Colors.grey[300]
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(height: 15, width: 100, color: Colors.grey[300]),
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
  }
}