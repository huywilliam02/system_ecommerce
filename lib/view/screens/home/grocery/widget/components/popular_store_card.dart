import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/title_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/store_screen.dart';

class PopularStoreCard extends StatelessWidget {
  final Store store;
  const PopularStoreCard({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Get.toNamed(RouteHelper.getStoreRoute(id: store.id, page: 'store'),
          arguments: StoreScreen(store: store, fromModule: false),
        );
      },
      child: Container(
        width: ResponsiveHelper.isDesktop(context) ? 315 : 260,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 0))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Stack(
            children: [
              CustomImage(
                image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}'
                    '/${store.coverPhoto}',
                fit: BoxFit.cover, width: double.infinity, height: 170,
              ),

              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  width: double.infinity, height: 87,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}'
                                  '/${store.logo}',
                              height: 40, width: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(store.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium),
                              Text(store.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),

                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Text(store.avgRating!.toStringAsFixed(1), style: robotoRegular),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Text('(${store.ratingCount})', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                                    ],
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),
                                  Text('${store.items!.length.toString()}' ' ' 'items'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}