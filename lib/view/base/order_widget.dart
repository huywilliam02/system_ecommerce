import 'package:citgroupvn_ecommerce_delivery/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_delivery/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_delivery/util/images.dart';
import 'package:citgroupvn_ecommerce_delivery/util/styles.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/order/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool isRunningOrder;
  final int orderIndex;
  const OrderWidget({Key? key, required this.orderModel, required this.isRunningOrder, required this.orderIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool parcel = orderModel.orderType == 'parcel';

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Column(children: [

        Row(children: [
          Text(
            '${parcel ? 'delivery_id'.tr : 'order_id'.tr}:',
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text('#${orderModel.id}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
          const Expanded(child: SizedBox()),
          Container(width: 7, height: 7, decoration: BoxDecoration(
            color: orderModel.paymentMethod == 'cash_on_delivery' ? Colors.red : Colors.green,
            shape: BoxShape.circle,
          )),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(
            orderModel.paymentMethod == 'cash_on_delivery' ? 'cod'.tr : orderModel.paymentMethod == 'partial_payment' ? 'partially_pay'.tr : 'digitally_paid'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
          Image.asset((parcel || orderModel.orderStatus == 'picked_up') ? Images.user : Images.house, width: 20, height: 15),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Expanded(child: Text(
            parcel ? 'customer_location'.tr : (parcel && orderModel.orderStatus == 'picked_up') ? 'receiver_location'.tr : 'store_location'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          )),
          parcel ? Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Text('parcel'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor)),
          ) : const SizedBox(),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
          const Icon(Icons.location_on, size: 20),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Expanded(child: Text(
            (parcel && orderModel.orderStatus != 'picked_up') ? orderModel.deliveryAddress!.address.toString() : (parcel && orderModel.orderStatus == 'picked_up') ? orderModel.receiverDetails!.address.toString() : orderModel.storeAddress ?? '',
            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          )),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Row(children: [
          Expanded(child: TextButton(
            onPressed: () {
              Get.toNamed(
                RouteHelper.getOrderDetailsRoute(orderModel.id),
                arguments: OrderDetailsScreen(orderId: orderModel.id, isRunningOrder: isRunningOrder, orderIndex: orderIndex),
              );
            },
            style: TextButton.styleFrom(minimumSize: const Size(1170, 45), padding: EdgeInsets.zero, shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall), side: BorderSide(width: 2, color: Theme.of(context).disabledColor),
            )),
            child: Text('details'.tr, textAlign: TextAlign.center, style: robotoBold.copyWith(
              color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeLarge,
            )),
          )),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(child: CustomButton(
            height: 45,
            onPressed: () async {
              String url;
              if(parcel && (orderModel.orderStatus == 'picked_up')) {
                url = 'https://www.google.com/maps/dir/?api=1&destination=${orderModel.receiverDetails!.latitude}'
                    ',${orderModel.receiverDetails!.longitude}&mode=d';
              }else if(parcel) {
                url = 'https://www.google.com/maps/dir/?api=1&destination=${orderModel.deliveryAddress!.latitude}'
                    ',${orderModel.deliveryAddress!.longitude}&mode=d';
              }else if(orderModel.orderStatus == 'picked_up') {
                url = 'https://www.google.com/maps/dir/?api=1&destination=${orderModel.deliveryAddress!.latitude}'
                    ',${orderModel.deliveryAddress!.longitude}&mode=d';
              }else {
                url = 'https://www.google.com/maps/dir/?api=1&destination=${orderModel.storeLat ?? '0'}'
                    ',${orderModel.storeLng ?? '0'}&mode=d';
              }
              if (await canLaunchUrlString(url)) {
                await launchUrlString(url, mode: LaunchMode.externalApplication);
              } else {
                showCustomSnackBar('${'could_not_launch'.tr} $url');
              }
            },
            buttonText: 'direction'.tr,
            icon: Icons.directions,
          )),
        ]),

      ]),
    );
  }
}
