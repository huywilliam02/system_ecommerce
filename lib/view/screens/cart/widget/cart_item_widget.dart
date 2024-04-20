import 'package:citgroupvn_ecommerce/data/model/response/cart_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:citgroupvn_ecommerce/controller/cart_controller.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/helper/cart_helper.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/item_bottom_sheet.dart';
import 'package:citgroupvn_ecommerce/view/base/quantity_button.dart';
import 'package:citgroupvn_ecommerce/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartItemWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;
  const CartItemWidget({Key? key, required this.cart, required this.cartIndex, required this.isAvailable, required this.addOns}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double? startingPrice = CartHelper.calculatePriceWithVariation(item: cart.item);
    double? endingPrice = CartHelper.calculatePriceWithVariation(item: cart.item, isStartingPrice: false);
    String? variationText = CartHelper.setupVariationText(cart: cart);
    String addOnText = CartHelper.setupAddonsText(cart: cart) ?? '';

    double? discount = cart.item!.storeDiscount == 0 ? cart.item!.discount : cart.item!.storeDiscount;
    String? discountType = cart.item!.storeDiscount == 0 ? cart.item!.discountType : 'percent';

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: InkWell(
        onTap: () {
          ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (con) => ItemBottomSheet(item: cart.item, cartIndex: cartIndex, cart: cart),
          ) : showDialog(context: context, builder: (con) => Dialog(
            child: ItemBottomSheet(item: cart.item, cartIndex: cartIndex, cart: cart),
          ));
        },
        child: Slidable(
          key: UniqueKey(),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.2,
            children: [
              SlidableAction(
                onPressed: (context) {
                  Get.find<CartController>().removeFromCart(cartIndex, item: cart.item);
                },
                backgroundColor: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(Get.find<LocalizationController>().isLtr ? Dimensions.radiusDefault : 0), left: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : Dimensions.radiusDefault)),
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: !ResponsiveHelper.isMobile(context) ? [const BoxShadow()] : [const BoxShadow(
                color: Colors.black12, blurRadius: 5, spreadRadius: 1,
              )],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImage(
                          image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${cart.item!.image}',
                          height: ResponsiveHelper.isDesktop(context) ? 90 : 65, width: ResponsiveHelper.isDesktop(context) ? 90 : 70, fit: BoxFit.cover,
                        ),
                      ),
                      isAvailable ? const SizedBox() : Positioned(
                        top: 0, left: 0, bottom: 0, right: 0,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.black.withOpacity(0.6)),
                          child: Text('not_available_now_break'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                            color: Colors.white, fontSize: 8,
                          )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Row(children: [
                        Flexible(
                          child: Text(
                            cart.item!.name!,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        ((Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && cart.item!.unitType != null && !Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation!)
                        || (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)) ? Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                          ),
                          child: Text(
                            Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! ? cart.item!.unitType ?? ''
                                : cart.item!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                          ),
                        ) : const SizedBox(),
                      ]),
                      const SizedBox(height: 2),

                      RatingBar(rating: cart.item!.avgRating, size: 12, ratingCount: cart.item!.ratingCount),
                      const SizedBox(height: 5),

                      Wrap(children: [
                        Text(
                          '${PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType)}'
                              '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: discount, discountType: discountType)}' : ''}',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                        ),
                        SizedBox(width: discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                        discount > 0 ? Text(
                          '${PriceConverter.convertPrice(startingPrice)}'
                              '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                          textDirection: TextDirection.ltr,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ) : const SizedBox(),
                      ]),

                      ResponsiveHelper.isDesktop(context) ? (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! && addOnText.isNotEmpty) ? Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                        child: Row(children: [
                          Text('${'addons'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                          Flexible(child: Text(
                            addOnText,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          )),
                        ]),
                      ) : const SizedBox() : const SizedBox(),

                      ResponsiveHelper.isDesktop(context) ? variationText!.isNotEmpty ? Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                        child: Row(children: [
                          Text(ResponsiveHelper.isDesktop(context) ? '' : '${'variations'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                          Flexible(child: Text(
                            variationText,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          )),
                        ]),
                      ) : const SizedBox() : const SizedBox(),
                    ]),
                  ),

                  GetBuilder<CartController>(
                    builder: (cartController) {
                      return Row(children: [
                        QuantityButton(
                          onTap: cartController.isLoading ? null : () {
                            if (cart.quantity! > 1) {
                              Get.find<CartController>().setQuantity(false, cartIndex, cart.stock, cart.quantityLimit);
                            }else {
                              Get.find<CartController>().removeFromCart(cartIndex, item: cart.item);
                            }
                          },
                          isIncrement: false,
                          showRemoveIcon: cart.quantity! == 1,
                        ),

                        Text(
                          cart.quantity.toString(),
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                        ),

                        QuantityButton(
                          onTap: cartController.isLoading ? null : () {
                            Get.find<CartController>().forcefullySetModule(Get.find<CartController>().cartList[0].item!.moduleId!);
                            Get.find<CartController>().setQuantity(true, cartIndex, cart.stock, cart.quantityLimit);
                          },
                          isIncrement: true,
                          color: cartController.isLoading ? Theme.of(context).disabledColor : null,
                        ),
                      ]);
                    }
                  ),

                  // !ResponsiveHelper.isMobile(context) ? Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  //   child: IconButton(
                  //     onPressed: () {
                  //       Get.find<CartController>().removeFromCart(cartIndex);
                  //     },
                  //     icon: const Icon(Icons.delete, color: Colors.red),
                  //   ),
                  // ) : const SizedBox(),
                ]),

                !ResponsiveHelper.isDesktop(context) ? (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! && addOnText.isNotEmpty) ? Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                  child: Row(children: [
                    SizedBox(width: ResponsiveHelper.isDesktop(context) ? 100 : 80),
                    Text('${'addons'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    Flexible(child: Text(
                      addOnText,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    )),
                  ]),
                ) : const SizedBox() : const SizedBox(),

                !ResponsiveHelper.isDesktop(context) ? variationText!.isNotEmpty ? Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                  child: Row(children: [
                    SizedBox(width: ResponsiveHelper.isDesktop(context) ? 100 : 80),
                    Text(ResponsiveHelper.isDesktop(context) ? '' : '${'variations'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    Flexible(child: Text(
                      variationText,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    )),
                  ]),
                ) : const SizedBox() : const SizedBox(),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
