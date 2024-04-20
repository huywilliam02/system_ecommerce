import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/theme_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
class PartialPayView extends StatelessWidget {
  final double totalPrice;
  final bool isPrescription;
  const PartialPayView({Key? key, required this.totalPrice, required this.isPrescription}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (orderController) {
        return Get.find<SplashController>().configModel!.partialPaymentStatus! && !isPrescription
        && Get.find<SplashController>().configModel!.customerWalletStatus == 1
        && Get.find<UserController>().userInfoModel!.walletBalance! > 0 ? AnimatedContainer(
          duration: const Duration(seconds: 2),
          decoration: BoxDecoration(
            color: Get.find<ThemeController>().darkTheme ? Theme.of(context).primaryColor.withOpacity(0.2) : Theme.of(context).primaryColor.withOpacity(0.05),
            border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            image: !ResponsiveHelper.isDesktop(context) ? DecorationImage(
              alignment: Alignment.bottomRight,
              colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.dstATop),
              image: const AssetImage(Images.partialWallet),
            ) : null,
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: ResponsiveHelper.isDesktop(context) ?  Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Row(children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text(
                    'applied'.tr,
                    style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                  )
                ]) : Text(
                  'do_you_want_to_use_now'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  PriceConverter.convertPrice(Get.find<UserController>().userInfoModel!.walletBalance!),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ),

                orderController.paymentMethodIndex == 1 ? Text(
                  '${'remaining_wallet_balance'.tr}: ${PriceConverter.convertPrice(Get.find<UserController>().userInfoModel!.walletBalance! - totalPrice)}',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ) : const SizedBox(),
              ]),
            ),

            InkWell(
              onTap: (){
                if(Get.find<UserController>().userInfoModel!.walletBalance! < totalPrice){
                  orderController.changePartialPayment();
                } else{
                  if(orderController.paymentMethodIndex != 1) {
                    orderController.setPaymentMethod(1);
                  }else{
                    orderController.setPaymentMethod(-1);
                  }
                }

              },
              child: Container(
                decoration: BoxDecoration(
                  color: orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                  border: Border.all(color: orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Colors.red : Theme.of(context).primaryColor, width: 0.5),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                child: Text(
                  orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? 'remove'.tr : 'use'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Colors.red : Colors.white),
                ),
              ),
            ),

          ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image.asset(Images.partialWallet, height: 30, width: 30),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  PriceConverter.convertPrice(Get.find<UserController>().userInfoModel!.walletBalance!),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(
                  orderController.isPartialPay ? 'has_paid_by_your_wallet'.tr : 'your_have_balance_in_your_wallet'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
              ]),

            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Row(children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(
                  'applied'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                )
              ]) : Text(
                'do_you_want_to_use_now'.tr,
                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
              ),

              InkWell(
                onTap: (){
                  if(Get.find<UserController>().userInfoModel!.walletBalance! < totalPrice){
                    orderController.changePartialPayment();
                  } else{
                    if(orderController.paymentMethodIndex != 1) {
                      orderController.setPaymentMethod(1);
                    }else{
                      orderController.setPaymentMethod(-1);
                    }
                  }

                },
                child: Container(
                  decoration: BoxDecoration(
                    color: orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                    border: Border.all(color: orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Colors.red : Theme.of(context).primaryColor, width: 0.5),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                  child: Text(
                    orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? 'remove'.tr : 'use'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: orderController.isPartialPay || orderController.paymentMethodIndex == 1 ? Colors.red : Colors.white),
                  ),
                ),
              ),

            ]),

            orderController.paymentMethodIndex == 1 ? Text(
              '${'remaining_wallet_balance'.tr}: ${PriceConverter.convertPrice(Get.find<UserController>().userInfoModel!.walletBalance! - totalPrice)}',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ) : const SizedBox(),

          ]),
        ) : const SizedBox();
      }
    );
  }
}
