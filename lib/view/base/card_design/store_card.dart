import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/controller/wishlist_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/module_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/new_tag.dart';
import 'package:citgroupvn_ecommerce/view/base/rating_bar.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/store_screen.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final bool? isNewStore;
  const StoreCard({Key? key, required this.store, this.isNewStore = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    double distance = Get.find<LocationController>().getRestaurantDistance(
      LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
    );

    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        if(Get.find<SplashController>().moduleList != null) {
          for(ModuleModel module in Get.find<SplashController>().moduleList!) {
            if(module.id == store.moduleId) {
              Get.find<SplashController>().setModule(module);
              break;
            }
          }
        }
        Get.toNamed(
          RouteHelper.getStoreRoute(id: store.id, page: 'store'),
          arguments: StoreScreen(store: store, fromModule: false),
        );
      },
      child: Stack(children: [

        Container(
          width: 300,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: ResponsiveHelper.isMobile(context) ? [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 1))] : null,
          ),
          child: Stack(children: [

            Column(children: [

              Expanded(
                flex: 5,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImage(
                      image: '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}''/${store.logo}',
                      height: 50, width: 50, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      SizedBox(
                        width: 190,
                        child: Text(store.name ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      !isPharmacy ? RatingBar(
                        rating: store.avgRating,
                        ratingCount: store.ratingCount,
                        size: 12,
                      ) : Row(children: [

                        Icon(Icons.storefront, size: 15, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Expanded(
                          child: Text(store.address ?? '',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      !isPharmacy ? Row(children: [

                        Icon(Icons.storefront, size: 15, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Flexible(
                          child: Text(store.address ?? '',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      ]) : Text('${store.items?.length}' ' ' 'items'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                    ]),
                  ),
                ]),
              ),
              Expanded(
                flex: 2,
                child: Row(children: [

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    ),
                    child: Row(children: [

                      Image.asset(Images.distanceLine, height: 15, width: 15),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text('${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}', style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text('from_you'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                    ]),
                  ),
                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    ),
                    child: Row(children: [

                      Image.asset(Images.clockIcon, height: 15, width: 15, color: Get.find<StoreController>().isOpenNow(store) ? const Color(0xffECA507) : Theme.of(context).colorScheme.error),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text(Get.find<StoreController>().isOpenNow(store) ? 'open_now'.tr : 'closed_now'.tr, style: robotoBold.copyWith(color: Get.find<StoreController>().isOpenNow(store) ? const Color(0xffECA507) : Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),
                    ]),
                  ),
                ]),
              ),
            ]),

           /* AddFavouriteView(
              top: 0,
              left: Get.find<LocalizationController>().isLtr ? null : 0,
              right: Get.find<LocalizationController>().isLtr ? 0 : null,
              item: Item(id: store.id),
            ),*/

            Positioned(
              top: 0,
              left: Get.find<LocalizationController>().isLtr ? null : 0,
              right: Get.find<LocalizationController>().isLtr ? 0 : null,
              child: GetBuilder<WishListController>(builder: (wishController) {
                bool isWished = wishController.wishStoreIdList.contains(store.id);
                return InkWell(
                  onTap: () {
                    if(Get.find<AuthController>().isLoggedIn()) {
                      isWished ? wishController.removeFromWishList(store.id, true)
                          : wishController.addToWishList(null, store, true);
                    }else {
                      showCustomSnackBar('you_are_not_logged_in'.tr);
                    }
                  },
                  child: Icon(
                    isWished ? Icons.favorite : Icons.favorite_border,  size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }),
            ),

          ]),
        ),

        const NewTag(),
      ]),
    );
  }
}
