import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/add_favourite_view.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/store_screen.dart';

class VisitAgainCard extends StatelessWidget {
  final Store store;
  final bool fromFood;
  const VisitAgainCard({Key? key, required this.store, required this.fromFood}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;

    return InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        Get.toNamed(
          RouteHelper.getStoreRoute(id: store.id, page: 'store'),
          arguments: StoreScreen(store: store, fromModule: false),
        );
      },
      child: Stack(children: [
        Container(
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
          ),
          child:  Padding(
            padding: const EdgeInsets.only(top: 40, bottom: Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              Flexible(child: Text(store.name ?? '', style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis)),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.star, size: 15, color: Theme.of(context).primaryColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(store.avgRating!.toStringAsFixed(1), style: robotoRegular),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text("(${store.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
              ]),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.storefront_outlined, size: 20, color: Theme.of(context).disabledColor),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Flexible(
                    child: Text(
                      store.address ?? '',
                      overflow: TextOverflow.ellipsis, maxLines: 1,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    ),
                  ),
                ]),
              ),

              Container(
                alignment: Alignment.center,
                height: 25, width: 200,
                child: ListView.builder(
                  itemCount: store.items!.length,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular((isPharmacy || isFood) ? 100 : Dimensions.radiusSmall),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                                '/${store.items![index].image}',
                                fit: BoxFit.cover, height: 25, width: 25,
                            ),
                          ),

                          index == store.items!.length -1 ? Positioned(
                            top: 0, left: 0,right: 0, bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular((isPharmacy || isFood) ? 100 : Dimensions.radiusSmall),
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Center(child: Text(
                                (store.itemCount! > 20) ? '20+' : '${store.itemCount}', style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall),
                              )),
                            ),
                          ) : const SizedBox(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),

        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 54, width: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(fromFood ? 100 : Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(fromFood ? 100 : Dimensions.radiusDefault),
              child: CustomImage(
                image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}'
                    '/${store.coverPhoto}',
                fit: BoxFit.cover, height: 54, width: 54,
              ),
            ),
          ),
        ),

        AddFavouriteView(
          top: 30, right: 10,
          item: Item(id: store.id),
        ),
      ]),
    );
  }
}
