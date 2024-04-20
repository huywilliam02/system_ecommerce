import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/coupon_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/parcel_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/config_model.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/condition_check_box.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/coupon_section.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/note_prescription_section.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/partial_pay_view.dart';

class BottomSection extends StatelessWidget {
  final OrderController orderController;
  final double total;
  final Module module;
  final double subTotal;
  final double discount;
  final CouponController couponController;
  final bool taxIncluded;
  final double tax;
  final double deliveryCharge;
  final StoreController storeController;
  final LocationController locationController;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? maxCodOrderAmount;
  final int? storeId;
  final double? taxPercent;
  final  double price;
  final double addOns;
  final Widget? checkoutButton;
  const BottomSection({Key? key, required this.orderController, required this.total, required this.module, required this.subTotal, required this.discount, required this.couponController, required this.taxIncluded, required this.tax, required this.deliveryCharge, required this.storeController, required this.locationController, required this.todayClosed, required this.tomorrowClosed, required this.orderAmount, this.maxCodOrderAmount, this.storeId, this.taxPercent, required this.price, required this.addOns, this.checkoutButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool takeAway = orderController.orderType == 'take_away';
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [

        isDesktop ? pricingView(context: context, takeAway: takeAway) : const SizedBox(),

        const SizedBox(height: Dimensions.paddingSizeSmall),

        /// Coupon
        isDesktop && !isGuestLoggedIn ? CouponSection(
          storeId: storeId, orderController: orderController, total: total, price: price,
          discount: discount, addOns: addOns, deliveryCharge: deliveryCharge,
        ) : const SizedBox(),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            ///Additional Note & prescription..
            NoteAndPrescriptionSection(orderController: orderController, storeId: storeId),

            isDesktop && !isGuestLoggedIn ? PartialPayView(totalPrice: total, isPrescription: storeId != null) : const SizedBox(),

            !isDesktop ? pricingView(context: context, takeAway: takeAway) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CheckoutCondition(orderController: orderController, parcelController: Get.find<ParcelController>()),

            const SizedBox(height: Dimensions.paddingSizeLarge),
            ResponsiveHelper.isDesktop(context) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text( 'total_amount'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                      storeId == null ? const SizedBox()
                          : Text(
                          'Once_your_order_is_confirmed_you_will_receive'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeOverSmall, color: Theme.of(context).disabledColor,
                          ),
                      ),
                    ],
                  ),
                  storeId == null ? const SizedBox()
                      : Text(
                    'a_notification_with_your_bill_total'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeOverSmall, color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
              PriceConverter.convertAnimationPrice(
                orderController.viewTotalPrice,
                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: orderController.isPartialPay ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              ),
              // Text(
              //   PriceConverter.convertPrice(orderController.viewTotalPrice), textDirection: TextDirection.ltr,
              //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              // ),
            ]) : const SizedBox(),
          ]),
        ),

        ResponsiveHelper.isDesktop(context) ? Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
          child: checkoutButton,
        ) : const SizedBox(),

      ]),
    );
  }

  Widget pricingView({required BuildContext context, required bool takeAway}) {
    return Column(children: [

      ResponsiveHelper.isDesktop(context) ? Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: Text('order_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        ),
      ) : const SizedBox(),

      Padding(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),
        child: Column(
          children: [
            storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(module.addOn! ? 'subtotal'.tr : 'item_price'.tr, style: robotoMedium),
              Text(PriceConverter.convertPrice(subTotal), style: robotoMedium, textDirection: TextDirection.ltr),
            ]) : const SizedBox(),
            SizedBox(height: storeId == null ? Dimensions.paddingSizeSmall : 0),

            storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('discount'.tr, style: robotoRegular),
              Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular, textDirection: TextDirection.ltr),
            ]) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            (couponController.discount! > 0 || couponController.freeDelivery) ? Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('coupon_discount'.tr, style: robotoRegular),
                (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery') ? Text(
                  'free_delivery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                ) : Text(
                  '(-) ${PriceConverter.convertPrice(couponController.discount)}',
                  style: robotoRegular, textDirection: TextDirection.ltr,
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ]) : const SizedBox(),

            storeId == null ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${'vat_tax'.tr} ${taxIncluded ? 'tax_included'.tr : ''} ($taxPercent%)', style: robotoRegular),
              Text((taxIncluded ? '' : '(+) ') + PriceConverter.convertPrice(tax), style: robotoRegular, textDirection: TextDirection.ltr),
            ]) : const SizedBox(),
            SizedBox(height: storeId == null ? Dimensions.paddingSizeSmall : 0),

            (!takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('delivery_man_tips'.tr, style: robotoRegular),
                Text('(+) ${PriceConverter.convertPrice(orderController.tips)}', style: robotoRegular, textDirection: TextDirection.ltr),
              ],
            ) : const SizedBox.shrink(),
            SizedBox(height: !takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

            (Get.find<AuthController>().isGuestLoggedIn() && orderController.guestAddress == null)
            ? const SizedBox() : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('delivery_fee'.tr, style: robotoRegular),
              orderController.distance == -1 ? Text(
                'calculating'.tr, style: robotoRegular.copyWith(color: Colors.red),
              ) : (deliveryCharge == 0 || (couponController.coupon != null && couponController.coupon!.couponType == 'free_delivery')) ? Text(
                'free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
              ) : Text(
                '(+) ${PriceConverter.convertPrice(deliveryCharge)}', style: robotoRegular, textDirection: TextDirection.ltr,
              ),
            ]),

            SizedBox(height: Get.find<SplashController>().configModel!.additionalChargeStatus! && !(Get.find<AuthController>().isGuestLoggedIn() && orderController.guestAddress == null) ? Dimensions.paddingSizeSmall : 0),

            Get.find<SplashController>().configModel!.additionalChargeStatus! ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(Get.find<SplashController>().configModel!.additionalChargeName!, style: robotoRegular),
              Text(
                '(+) ${PriceConverter.convertPrice(Get.find<SplashController>().configModel!.additionCharge)}',
                style: robotoRegular, textDirection: TextDirection.ltr,
              ),
            ]) : const SizedBox(),
            SizedBox(height: orderController.isPartialPay ? Dimensions.paddingSizeSmall : 0),

            orderController.isPartialPay ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('paid_by_wallet'.tr, style: robotoRegular),
              Text('(-) ${PriceConverter.convertPrice(Get.find<UserController>().userInfoModel!.walletBalance!)}', style: robotoRegular, textDirection: TextDirection.ltr),
            ]) : const SizedBox(),
            SizedBox(height: orderController.isPartialPay ? Dimensions.paddingSizeSmall : 0),

            orderController.isPartialPay ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'due_payment'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              ),
              PriceConverter.convertAnimationPrice(
                orderController.viewTotalPrice,
                textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: !ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).primaryColor),
              )
            ]) : const SizedBox(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
            ),
          ],
        ),
      ),

    ]);
  }
}
