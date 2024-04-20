import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/cart_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/config_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/time_slot_bottom_sheet.dart';
class TimeSlotSection extends StatelessWidget {
  final int? storeId;
  final StoreController storeController;
  final List<CartModel?>? cartList;
  final JustTheController tooltipController2;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  final OrderController orderController;
  const TimeSlotSection({
    Key? key, this.storeId, required this.storeController, this.cartList, required this.tooltipController2,
    required this.tomorrowClosed, required this.todayClosed, this.module, required this.orderController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      storeId == null && storeController.store!.scheduleOrder! && cartList![0]!.item!.availableDateStarts == null ? Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('preference_time'.tr, style: robotoMedium),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            JustTheTooltip(
              backgroundColor: Colors.black87,
              controller: tooltipController2,
              preferredDirection: AxisDirection.right,
              tailLength: 14,
              tailBaseWidth: 20,
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('schedule_time_tool_tip'.tr,style: robotoRegular.copyWith(color: Colors.white)),
              ),
              child: InkWell(
                onTap: () => tooltipController2.showTooltip(),
                child: const Icon(Icons.info_outline),
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          InkWell(
            onTap: (){
              if(ResponsiveHelper.isDesktop(context)){
                showDialog(context: context, builder: (con) => Dialog(
                  child: TimeSlotBottomSheet(
                    tomorrowClosed: tomorrowClosed,
                    todayClosed: todayClosed, module: module,
                  ),
                ));
              }else{
                showModalBottomSheet(
                  context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                  builder: (con) => TimeSlotBottomSheet(
                    tomorrowClosed: tomorrowClosed,
                    todayClosed: todayClosed, module: module,
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
              ),
              height: 50,
              child: Row(children: [
                const SizedBox(width: Dimensions.paddingSizeLarge),
                Expanded(child: ((orderController.selectedDateSlot == 0 && todayClosed) || (orderController.selectedDateSlot == 1 && tomorrowClosed))
                    ? Center(child: Text(module!.showRestaurantText! ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr))
                    : Text(orderController.preferableTime.isNotEmpty ? orderController.preferableTime : 'instance'.tr)),

                const Icon(Icons.arrow_drop_down, size: 28),
                Icon(Icons.access_time_filled_outlined, color: Theme.of(context).primaryColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              ]),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ]),
      ) : const SizedBox(),

      SizedBox(height: storeId == null && storeController.store!.scheduleOrder! && cartList![0]!.item!.availableDateStarts == null ? Dimensions.paddingSizeSmall : 0),

    ]);
  }
}
