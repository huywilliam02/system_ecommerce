import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/parcel_category_model.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/screens/parcel/widget/deliver_item_card.dart';
class ParcelBottomSheet extends StatelessWidget {
  final List<ParcelCategoryModel>? parcelCategoryList;
  const ParcelBottomSheet({Key? key, this.parcelCategoryList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Stack(
        children: [
          Column(mainAxisSize: MainAxisSize.min, children: [

            const SizedBox(height: Dimensions.paddingSizeLarge),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [

                  Align(alignment: Alignment.topLeft, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('select_and_deliver'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text('what_are_you_wish_to_send'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                    ],
                  )),
                  const SizedBox(height: Dimensions.paddingSizeLarge),


                  Padding(
                    padding: const EdgeInsets.only(
                      right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault,
                      bottom: Dimensions.paddingSizeDefault
                    ),
                    child: parcelCategoryList != null ? parcelCategoryList!.isNotEmpty ? GridView.builder(
                      controller: ScrollController(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: Dimensions.paddingSizeSmall,
                        mainAxisSpacing: Dimensions.paddingSizeSmall,
                        mainAxisExtent: 75,
                      ),
                      itemCount: parcelCategoryList!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Get.back();
                            Get.toNamed(RouteHelper.getParcelLocationRoute(parcelCategoryList![index]));
                          },
                          child: DeliverItemCard(
                            isDeliverItem: true,
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}'
                                '/${parcelCategoryList![index].image}',
                            itemName: parcelCategoryList![index].name!,
                            description: parcelCategoryList![index].description!,
                          ),
                        );
                      },
                    ) : const SizedBox() : const Center(child: CircularProgressIndicator()),
                  ),
                ]),
              ),
            ),

          ]),

          Positioned(
            top: 5, right: 10,
            child: InkWell(
              onTap: () => Get.back(),
              child: Container(
                padding:  const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 5)],
                ),
                child: const Icon(Icons.close, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
