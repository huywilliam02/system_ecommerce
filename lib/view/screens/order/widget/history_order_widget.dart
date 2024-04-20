import 'package:citgroupvn_ecommerce_delivery/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_delivery/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_delivery/util/styles.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/order/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryOrderWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool isRunning;
  final int index;
  const HistoryOrderWidget({Key? key, required this.orderModel, required this.isRunning, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool parcel = orderModel.orderType == 'parcel';

    return InkWell(
      onTap: () => Get.toNamed(
        RouteHelper.getOrderDetailsRoute(orderModel.id),
        arguments: OrderDetailsScreen(orderId: orderModel.id, isRunningOrder: isRunning, orderIndex: index),
      ),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5)],
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Row(children: [

          Container(
            height: 70, width: 70, alignment: Alignment.center,
            decoration: parcel ? BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ) : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: CustomImage(
                image: parcel ? '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}/${orderModel.parcelCategory != null
                    ? orderModel.parcelCategory!.image : ''}'
                    : '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${orderModel.storeLogo ?? ''}',
                height: parcel ? 45 : 70, width: parcel ? 45 : 70, fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(children: [
                Text(
                  '${parcel ? 'delivery_id'.tr : 'order_id'.tr}:',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Expanded(child: Text(
                  '#${orderModel.id}',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                )),
                parcel ? Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Text('parcel'.tr, style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                  )),
                ) : const SizedBox(),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(
                parcel ? orderModel.parcelCategory != null ? orderModel.parcelCategory!.name! : 'no_parcel_category_data_found'.tr : orderModel.storeName ?? 'no_store_data_found'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(children: [
                const Icon(Icons.access_time, size: 15),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  DateConverter.dateTimeStringToDateTime(orderModel.createdAt!),
                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                ),
              ]),

            ]),
          ),

        ]),
      ),
    );
  }
}
