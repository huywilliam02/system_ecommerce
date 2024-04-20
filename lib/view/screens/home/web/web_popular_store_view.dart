import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/wishlist_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/discount_tag.dart';
import 'package:citgroupvn_ecommerce/view/base/hover/on_hover.dart';
import 'package:citgroupvn_ecommerce/view/base/not_available_widget.dart';
import 'package:citgroupvn_ecommerce/view/base/rating_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/title_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class WebPopularStoreView extends StatelessWidget {
  final StoreController storeController;
  final bool isPopular;
  const WebPopularStoreView({Key? key, required this.storeController, required this.isPopular}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Store>? storeList = isPopular ? storeController.popularStoreList : storeController.latestStoreList;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
          child: TitleWidget(title: isPopular ? Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
              ? 'popular_restaurants'.tr : 'popular_stores'.tr : '${'new_on'.tr} ${AppConstants.appName}'),
        ),

        storeList != null ? GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, childAspectRatio: (1/0.8),
            crossAxisSpacing: Dimensions.paddingSizeExtremeLarge, mainAxisSpacing: Dimensions.paddingSizeExtremeLarge,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          itemCount: storeList.length > 7 ? 8 : storeList.length,
          itemBuilder: (context, index){

            return OnHover(
              isItem: true,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      Get.toNamed(
                        RouteHelper.getStoreRoute(id: storeList[index].id, page: 'store'),
                        arguments: StoreScreen(store: storeList[index], fromModule: false),
                      );
                    },
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Container(
                      width: 500,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.2)),
                        // boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                      ),
                      padding: const EdgeInsets.all(1),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                        Stack(children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}'
                                  '/${storeList[index].coverPhoto}',
                              height: 120, width: 500, fit: BoxFit.cover,
                            ),
                          ),
                          DiscountTag(
                            discount: storeController.getDiscount(storeList[index]),
                            discountType: storeController.getDiscountType(storeList[index]),
                            freeDelivery: storeList[index].freeDelivery,
                          ),
                          storeController.isOpenNow(storeList[index]) ? const SizedBox() : NotAvailableWidget(isStore: true, fontSize: Dimensions.fontSizeExtraSmall, isAllSideRound: false),
                          Positioned(
                            top: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall,
                            child: GetBuilder<WishListController>(builder: (wishController) {
                              bool isWished = wishController.wishStoreIdList.contains(storeList[index].id);
                              return InkWell(
                                onTap: () {
                                  if(Get.find<AuthController>().isLoggedIn()) {
                                    isWished ? wishController.removeFromWishList(storeList[index].id, true)
                                        : wishController.addToWishList(null, storeList[index], true);
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
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeExtraSmall),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(
                                storeList[index].name!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Text(
                                storeList[index].address!,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              RatingBar(
                                rating: storeList[index].avgRating,
                                ratingCount: storeList[index].ratingCount,
                                size: 15,
                              ),
                            ]),
                          ),
                        ),

                      ]),
                    ),
                  ),

                  Visibility(
                    visible: index == 7,
                    child: Positioned(
                      top: 0, bottom: 0, left: 0, right: 0,
                      child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute(isPopular ? 'popular' : 'latest')),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                            gradient: LinearGradient(colors: [
                              Theme.of(context).primaryColor.withOpacity(0.7),
                              Theme.of(context).primaryColor.withOpacity(1),
                            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '+${storeList.length-5}\n${'more'.tr}', textAlign: TextAlign.center,
                            style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ) : PopularStoreShimmer(storeController: storeController),
      ],
    );
  }
}

class PopularStoreShimmer extends StatelessWidget {
  final StoreController storeController;
  const PopularStoreShimmer({Key? key, required this.storeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, childAspectRatio: (1/0.7),
        crossAxisSpacing: Dimensions.paddingSizeLarge, mainAxisSpacing: Dimensions.paddingSizeLarge,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      itemCount: 8,
      itemBuilder: (context, index){
        return Container(
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
      },
    );
  }
}

