import 'package:citgroupvn_ecommerce_delivery/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_delivery/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_delivery/util/images.dart';
import 'package:citgroupvn_ecommerce_delivery/util/styles.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/confirmation_dialog.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/order/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderRequestWidget extends StatelessWidget {
  final OrderModel orderModel;
  final int index;
  final bool fromDetailsPage;
  final Function onTap;
  const OrderRequestWidget({Key? key, required this.orderModel, required this.index, required this.onTap, this.fromDetailsPage = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool parcel = orderModel.orderType == 'parcel';

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: GetBuilder<OrderController>(builder: (orderController) {
        return Column(children: [

          Row(children: [
            Container(
              height: 45, width: 45, alignment: Alignment.center,
              decoration: parcel ? BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ) : null,
              child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), child: CustomImage(
                image: parcel ? '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}/${orderModel.parcelCategory != null
                    ? orderModel.parcelCategory!.image : ''}' : '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${orderModel.storeLogo ?? ''}',
                height: parcel ? 30 : 45, width: parcel ? 30 : 45, fit: BoxFit.cover,
              )),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                parcel ? orderModel.parcelCategory != null ? orderModel.parcelCategory!.name ?? ''
                    : '' : orderModel.storeName ?? 'no_store_data_found'.tr, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
              Text(
                parcel ? orderModel.parcelCategory != null ? orderModel.parcelCategory!.description ?? '' : '' : orderModel.storeAddress ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Theme.of(context).primaryColor, width: 1),
              ),
              child: Column(children: [
                (Get.find<SplashController>().configModel!.showDmEarning! && Get.find<AuthController>().profileModel != null
                    && Get.find<AuthController>().profileModel!.earnings == 1) ? Text(
                  PriceConverter.convertPrice(orderModel.originalDeliveryCharge! + orderModel.dmTips!),
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                ) : const SizedBox(),

                Text(
                  orderModel.paymentMethod == 'cash_on_delivery' ? 'cod'.tr : orderModel.paymentMethod == 'wallet' ? 'wallet'.tr : 'digitally_paid'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Container(
            padding: parcel ? const EdgeInsets.all(Dimensions.paddingSizeExtraSmall) : null,
            decoration: parcel ? BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ) : null,
            child: Text(
              parcel ? 'parcel'.tr : '${orderModel.detailsCount} ${orderModel.detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: parcel ? Theme.of(context).primaryColor : null),
            ),
          ),
          SizedBox(height: parcel ? Dimensions.paddingSizeExtraSmall : 0),
          Text(
            '${DateConverter.timeDistanceInMin(orderModel.createdAt!)} ${'mins_ago'.tr}',
            style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(children: [
            Expanded(child: TextButton(
              onPressed: () => Get.dialog(ConfirmationDialog(
                icon: Images.warning, title: 'are_you_sure_to_ignore'.tr,
                description: parcel ? 'you_want_to_ignore_this_delivery'.tr : 'you_want_to_ignore_this_order'.tr,
                onYesPressed: ()  {
                  if(Get.isSnackbarOpen){
                    Get.back();
                  }
                  orderController.ignoreOrder(index);
                  Get.back();
                  showCustomSnackBar('order_ignored'.tr, isError: false);
                },
              ), barrierDismissible: false),
              style: TextButton.styleFrom(
                minimumSize: const Size(1170, 40), padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  side: BorderSide(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!),
                ),
              ),
              child: Text('ignore'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: Dimensions.fontSizeLarge,
              )),
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: CustomButton(
              height: 40,
              buttonText: 'accept'.tr,
              onPressed: () => Get.dialog(ConfirmationDialog(
                icon: Images.warning, title: 'are_you_sure_to_accept'.tr,
                description: parcel ? 'you_want_to_accept_this_delivery'.tr : 'you_want_to_accept_this_order'.tr,
                onYesPressed: () {
                  orderController.acceptOrder(orderModel.id, index, orderModel).then((isSuccess) {
                    if(isSuccess) {
                      onTap();
                      orderModel.orderStatus = (orderModel.orderStatus == 'pending' || orderModel.orderStatus == 'confirmed')
                          ? 'accepted' : orderModel.orderStatus;
                      Get.toNamed(
                        RouteHelper.getOrderDetailsRoute(orderModel.id),
                        arguments: OrderDetailsScreen(
                          orderId: orderModel.id, isRunningOrder: true, orderIndex: orderController.currentOrderList!.length-1,
                        ),
                      );
                    }else {
                      Get.find<OrderController>().getLatestOrders();
                    }
                  });
                },
              ), barrierDismissible: false),
            )),
          ]),

        ]);
      }),
    );
  }
}
