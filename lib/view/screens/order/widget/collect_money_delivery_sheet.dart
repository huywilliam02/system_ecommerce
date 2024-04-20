import 'package:citgroupvn_ecommerce_delivery/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_delivery/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_delivery/util/images.dart';
import 'package:citgroupvn_ecommerce_delivery/util/styles.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CollectMoneyDeliverySheet extends StatelessWidget {
  final OrderModel currentOrderModel;
  final bool? verify;
  final bool? cod;
  final double? orderAmount;
  final bool isSenderPay;
  final bool? isParcel;
  const CollectMoneyDeliverySheet({Key? key, required this.currentOrderModel, required this.verify, required this.orderAmount, required this.cod, this.isSenderPay = false, this.isParcel = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('----vvvvv---: $cod');
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {

        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              height: 5, width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                color: Theme.of(context).disabledColor.withOpacity(0.5),
              ),
            ),

            cod! ? Column(children: [
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Image.asset(Images.deliveredSuccess, height: 100, width: 100),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                'collect_money_from_customer'.tr, textAlign: TextAlign.center,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '${'order_amount'.tr}:', textAlign: TextAlign.center,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  PriceConverter.convertPrice(orderAmount), textAlign: TextAlign.center,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ),
              ]),
              SizedBox(height: verify! ? 20 : 40),
            ]) : Column(children: [
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Image.asset(Images.deliveredSuccess, height: 100, width: 100),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                'want_to_complete_the_order'.tr, textAlign: TextAlign.center,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              SizedBox(height: verify! ? 20 : 40),
            ]),

           !orderController.isLoading ? CustomButton(
              buttonText: 'ok'.tr,
              radius: Dimensions.radiusDefault,
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              onPressed: () {

                if(verify!){
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                } else{
                  Get.find<OrderController>().updateOrderStatus(currentOrderModel, isSenderPay ? 'picked_up' : 'delivered', parcel: isParcel).then((success) {
                    if(success) {
                      Get.find<AuthController>().getProfile();
                      Get.find<OrderController>().getCurrentOrders();
                      if(!isSenderPay) {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      }
                    }
                  });
                }
              },
            ) : const Center(child: CircularProgressIndicator()),

            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),
        );
      }),
    );
  }
}
