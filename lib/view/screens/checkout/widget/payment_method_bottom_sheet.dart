import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/offline_payment_button.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/payment_button_new.dart';
class PaymentMethodBottomSheet extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final int? storeId;
  final double totalPrice;
  const PaymentMethodBottomSheet({Key? key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.storeId, required this.totalPrice, required this.isOfflinePaymentActive}) : super(key: key);

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  final JustTheController tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    if(!Get.find<AuthController>().isGuestLoggedIn()) {
      double walletBalance = Get.find<UserController>().userInfoModel!.walletBalance!;
      if(walletBalance < widget.totalPrice){
        canSelectWallet = false;
      }
      if(Get.find<OrderController>().isPartialPay){
        notHideWallet = false;
        if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'cod'){
          notHideCod = true;
          notHideDigital = false;
        } else if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'digital_payment'){
          notHideCod = false;
          notHideDigital = true;
        } else if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'both'){
          notHideCod = true;
          notHideDigital = true;
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return SizedBox(
      width: 550,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(Dimensions.radiusLarge),
            bottom: Radius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusLarge : 0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          ResponsiveHelper.isDesktop(context) ? Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () => Get.back(),
              child: Container(
                height: 30, width: 30,
                margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
                child: const Icon(Icons.clear),
              ),
            ),
          ) : Align(
            alignment: Alignment.center,
            child: Container(
              height: 4, width: 35,
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          Flexible(
            child: SingleChildScrollView(
              child: GetBuilder<OrderController>(
                builder: (orderController) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Align(alignment: Alignment.center, child: Text('payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      notHideCod ? Text('choose_payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)) : const SizedBox(),
                      SizedBox(height: notHideCod ? Dimensions.paddingSizeExtraSmall : 0),

                      notHideCod ? Text(
                        'click_one_of_the_option_below'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      ) : const SizedBox(),
                      SizedBox(height: notHideCod ? Dimensions.paddingSizeLarge : 0),

                      Row(children: [
                        widget.isCashOnDeliveryActive && notHideCod ? Expanded(
                          child: PaymentButtonNew(
                            icon: Images.codIcon,
                            title: 'cash_on_delivery'.tr,
                            isSelected: orderController.paymentMethodIndex == 0,
                            onTap: () {
                              orderController.setPaymentMethod(0);
                            },
                          ),
                        ) : const SizedBox(),
                        SizedBox(width: widget.storeId == null && widget.isWalletActive && notHideWallet && isLoggedIn ? Dimensions.paddingSizeLarge : 0),

                        widget.storeId == null && widget.isWalletActive && notHideWallet && isLoggedIn ? Expanded(
                          child: PaymentButtonNew(
                            icon: Images.partialWallet,
                            title: 'pay_via_wallet'.tr,
                            isSelected: orderController.paymentMethodIndex == 1,
                            onTap: () {
                              if(canSelectWallet) {
                                orderController.setPaymentMethod(1);
                              } else if(orderController.isPartialPay){
                                showCustomSnackBar('you_can_not_user_wallet_in_partial_payment'.tr);
                                Get.back();
                              } else{
                                showCustomSnackBar('your_wallet_have_not_sufficient_balance'.tr);
                                Get.back();
                              }
                            },
                          ),
                        ) : const SizedBox(),

                      ]),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      widget.storeId == null && widget.isDigitalPaymentActive && notHideDigital ? Row(children: [
                        Text('pay_via_online'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                        Text(
                          'faster_and_secure_way_to_pay_bill'.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                        ),
                      ]) : const SizedBox(),
                      SizedBox(height: widget.storeId == null && widget.isDigitalPaymentActive && notHideDigital ? Dimensions.paddingSizeLarge : 0),

                      widget.storeId == null && widget.isDigitalPaymentActive && notHideDigital ? ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                          itemBuilder: (context, index) {
                            bool isSelected = orderController.paymentMethodIndex == 2 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == orderController.digitalPaymentName;
                          return InkWell(
                            onTap: (){
                              orderController.setPaymentMethod(2);
                              orderController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 0.3)
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                              child: Row(children: [
                                Container(
                                  height: 20, width: 20,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                      border: Border.all(color: Theme.of(context).disabledColor)
                                  ),
                                  child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeDefault),

                                Expanded(
                                  child: Text(
                                    Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                    overflow: TextOverflow.ellipsis, maxLines: 1,
                                  ),
                                ),

                                CustomImage(
                                  height: 20, fit: BoxFit.contain,
                                  image: '${Get.find<SplashController>().configModel!.baseUrls!.gatewayImageUrl}/${Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImage!}',
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                              ]),
                            ),
                        );
                          }) : const SizedBox(),


                      OfflinePaymentButton(
                        isSelected: orderController.paymentMethodIndex == 3,
                        offlineMethodList: orderController.offlineMethodList!,
                        isOfflinePaymentActive: widget.isOfflinePaymentActive,
                        onTap: () {
                          orderController.setPaymentMethod(3);
                        },
                        orderController: orderController, tooltipController: tooltipController,
                      ),
                    ],
                  );
                }
              ),
            ),
          ),

          SafeArea(
            child: CustomButton(
              buttonText: 'select'.tr,
              onPressed: () => Get.back(),
            ),
          ),

        ]),
      ),
    );
  }
}
