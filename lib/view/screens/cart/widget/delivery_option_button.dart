import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryOptionButton extends StatefulWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final bool fromWeb;
  final double total;
  const DeliveryOptionButton({Key? key, required this.value, required this.title, required this.charge, required this.isFree, this.fromWeb = false, required this.total}) : super(key: key);

  @override
  State<DeliveryOptionButton> createState() => _DeliveryOptionButtonState();
}

class _DeliveryOptionButtonState extends State<DeliveryOptionButton> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), (){
      Get.find<OrderController>().setOrderType(Get.find<SplashController>().configModel!.homeDeliveryStatus == 1
          && Get.find<StoreController>().store!.delivery! ? 'delivery' : 'take_away', notify: true);
    });
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (orderController) {
        bool select = orderController.orderType == widget.value;

        return InkWell(
          onTap: () {
            orderController.setOrderType(widget.value);
            orderController.setInstruction(-1);

            if(orderController.orderType == 'take_away') {
              if(orderController.isPartialPay) {
                double tips = 0;
                try{
                  tips = double.parse(orderController.tipController.text);
                } catch(_) {}
                orderController.checkBalanceStatus(widget.total, widget.charge! + tips);
              }
            } else {
              if(orderController.isPartialPay){
                orderController.changePartialPayment();
              } else {
                orderController.setPaymentMethod(-1);
              }

            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: select  ? widget.fromWeb ? Theme.of(context).primaryColor.withOpacity(0.05) : Theme.of(context).cardColor : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: select ? Theme.of(context).primaryColor : Colors.transparent),
              boxShadow: [BoxShadow(color: select ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent, blurRadius: 10)]
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            child: Row(
              children: [
                Radio(
                  value: widget.value,
                  groupValue: orderController.orderType,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (String? value) {
                    orderController.setOrderType(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text(widget.title, style: robotoMedium.copyWith(color: select ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color)),
                const SizedBox(width: 5),

                // Text(
                //   '(${(value == 'take_away' || isFree!) ? 'free'.tr : charge != -1 ? PriceConverter.convertPrice(charge) : 'calculating'.tr})',
                //   style: robotoMedium,
                // ),

              ],
            ),
          ),
        );
      },
    );
  }
}
