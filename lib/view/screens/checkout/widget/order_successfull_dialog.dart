import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/zone_response_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/payment_failed_dialog.dart';

class OrderSuccessfulDialog extends StatefulWidget {
  final String? orderID;
  const OrderSuccessfulDialog({Key? key, required this.orderID}) : super(key: key);

  @override
  State<OrderSuccessfulDialog> createState() => _OrderSuccessfulDialogState();
}

class _OrderSuccessfulDialogState extends State<OrderSuccessfulDialog> {
  bool? _isCashOnDeliveryActive = false;

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().trackOrder(widget.orderID.toString(), null, false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        await Get.offAllNamed(RouteHelper.getInitialRoute());
        return false;
      },
      child: GetBuilder<OrderController>(builder: (orderController){
          double total = 0;
          bool success = true;
          bool parcel = false;
          double? maximumCodOrderAmount;
          if(orderController.trackModel != null) {
            total = ((orderController.trackModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
            success = orderController.trackModel!.paymentStatus == 'paid' || orderController.trackModel!.paymentMethod == 'cash_on_delivery'
                || orderController.trackModel!.paymentMethod == 'partial_payment';
            parcel = orderController.trackModel!.paymentMethod == 'parcel';
            for(ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
              for(Modules m in zData.modules!) {
                if(m.id == Get.find<SplashController>().module!.id) {
                  maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
                  break;
                }
              }
              if(zData.id ==  Get.find<LocationController>().getUserAddress()!.zoneId){
                _isCashOnDeliveryActive = zData.cashOnDelivery;
              }
            }

            if (!success && !Get.isDialogOpen! && orderController.trackModel!.orderStatus != 'canceled') {
              Future.delayed(const Duration(seconds: 1), () {
                Get.dialog(PaymentFailedDialog(orderID: widget.orderID, isCashOnDelivery: _isCashOnDeliveryActive, orderAmount: total, maxCodOrderAmount: maximumCodOrderAmount, orderType: parcel ? 'parcel' : 'delivery'), barrierDismissible: false);
              });
            }
          }

          return orderController.trackModel != null ? Center(
            child: Container(
              width: 500,  height: 390,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                ResponsiveHelper.isDesktop(context) ? Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.clear),
                  ),
                ) : const SizedBox(),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                Image.asset(success ? Images.checked : Images.warning, width: 55, height: 55 ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text(
                  success ? parcel ? 'you_placed_the_parcel_request_successfully'.tr
                      : 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                  child: Text(
                    success ? parcel ? 'your_parcel_request_is_placed_successfully'.tr
                        : 'your_order_is_placed_successfully'.tr : 'your_order_is_failed_to_place_because'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                // const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                //
                // Padding(
                //   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                //   child: CustomButton( width: 400, height: 55, buttonText: 'back_to_home'.tr, isBold: false, onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute())),
                // ),

            ])),
          ) : const Center(child: CircularProgressIndicator());
        })
    );
  }
}