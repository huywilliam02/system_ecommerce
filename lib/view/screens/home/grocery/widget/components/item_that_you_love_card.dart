import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/add_favourite_view.dart';
import 'package:citgroupvn_ecommerce/view/base/cart_count_view.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/discount_tag.dart';
import 'package:citgroupvn_ecommerce/view/base/hover/on_hover.dart';
import 'package:citgroupvn_ecommerce/view/base/not_available_widget.dart';

class ItemThatYouLoveCard extends StatelessWidget {
  final Item item;
  const ItemThatYouLoveCard({Key? key, required this.item,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? discount = item.storeDiscount == 0 ? item.discount : item.storeDiscount;
    String? discountType = item.storeDiscount == 0 ? item.discountType : 'percent';
    return OnHover(
      isItem: true,
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: ResponsiveHelper.isMobile(context) ? [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))] : null,
          ),
          child: Column(children: [

            Expanded(
              flex: 7,
              child: Stack(clipBehavior: Clip.none, children: [

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImage(
                      image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                          '/${item.image}',
                      fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                    ),
                  ),
                ),

                DiscountTag(
                  discount: discount,
                  discountType: discountType,
                  freeDelivery: false,
                ),

                AddFavouriteView(
                  item: item,
                ),

                Get.find<ItemController>().isAvailable(item) ? const SizedBox() : const NotAvailableWidget(),

                Positioned(
                  bottom: -10, left: 0, right: 0,
                  child: CartCountView(
                    item: item,
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        width: 65, height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(112),
                          color: Theme.of(context).primaryColor,
                          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
                        ),
                        child: Text("add".tr, style: robotoBold.copyWith(color: Theme.of(context).cardColor)),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Expanded(
              flex: Get.find<LocalizationController>().isLtr ? 3 : 4,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Text(item.name ?? '', style: robotoBold),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                    Icon(Icons.star, size: 15, color: Theme.of(context).primaryColor),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(item.avgRating.toString(), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                  ]),

                  (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(
                    item.unitType ?? '',
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  ) : const SizedBox(),

                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                    item.discount != null && item.discount! > 0  ? Text(
                      PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                        decoration: TextDecoration.lineThrough,
                      ), textDirection: TextDirection.ltr,
                    ) : const SizedBox(),
                    SizedBox(width: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                    Text(
                      PriceConverter.convertPrice(
                        Get.find<ItemController>().getStartingPrice(item), discount: item.discount,
                        discountType: item.discountType,
                      ),
                      textDirection: TextDirection.ltr, style: robotoMedium,
                    ),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}