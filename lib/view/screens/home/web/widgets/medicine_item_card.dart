import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/add_favourite_view.dart';
import 'package:citgroupvn_ecommerce/view/base/cart_count_view.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/discount_tag.dart';
import 'package:citgroupvn_ecommerce/view/base/hover/on_hover.dart';
import 'package:citgroupvn_ecommerce/view/base/organic_tag.dart';

class MedicineItemCard extends StatelessWidget {
  final Item item;
  const MedicineItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;
    double? discount = item.storeDiscount == 0 ? item.discount : item.storeDiscount;
    String? discountType = item.storeDiscount == 0 ? item.discountType : 'percent';

    return OnHover(
      isItem: true,
      child: Container(
        width: ResponsiveHelper.isDesktop(context) ? 230 : isShop ? 200 : 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
        ),
        child: InkWell(
          hoverColor: Colors.transparent,
          onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Expanded(
              flex: 5,
              child: Stack(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radiusDefault),
                    topRight: Radius.circular(Dimensions.radiusDefault),
                  ),
                  child: CustomImage(
                    placeholder: Images.placeholder,
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                        '/${item.image}',
                    fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                  ),
                ),

                AddFavouriteView(
                  item: item,
                ),

                DiscountTag(
                  discount: discount,
                  discountType: discountType,
                  freeDelivery: false,
                ),

                OrganicTag(item: item, placeInImage: false),

                isShop ? const SizedBox() : Positioned(
                  bottom: 10, right: 10,
                  child: CartCountView(
                    item: item,
                    child: Container(
                      height: 25, width: 25,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                      child: Icon(Icons.add, size: 20, color: Theme.of(context).cardColor),
                    ),
                  ),
                ),
              ]),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: isShop ? CrossAxisAlignment.center : CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

                  Text(
                    item.storeName ?? '',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  ),

                  Text(item.name ?? '', style: robotoBold,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),

                  isShop ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.star, size: 15, color: Theme.of(context).primaryColor),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(item.avgRating.toString(), style: robotoRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text("(${item.ratingCount})", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),

                  ]) : const SizedBox(),
                  // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                  item.discount != null && item.discount! > 0  ? Text(
                    PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                      decoration: TextDecoration.lineThrough,
                    ), textDirection: TextDirection.ltr,
                  ) : const SizedBox(),
                  // SizedBox(height: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),


                  Align(
                    alignment: isShop ? Alignment.center : Alignment.centerLeft,
                    child: Row(mainAxisAlignment: isShop ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                      Text(
                        PriceConverter.convertPrice(
                          Get.find<ItemController>().getStartingPrice(item), discount: item.discount,
                          discountType: item.discountType,
                        ),
                        textDirection: TextDirection.ltr, style: robotoMedium,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(
                        '/ ${ item.unitType ?? ''}',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                      ) : const SizedBox(),
                    ]),
                  ),
                ],
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