import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebPaymentButton extends StatelessWidget {
  final String icon;
  final String title;
  final String subTitle;
  final bool isSelected;
  final Function onTap;
  const WebPaymentButton({Key? key, required this.isSelected, required this.icon, required this.title, required this.onTap, required this.subTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: InkWell(
          onTap: onTap as void Function()?,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.30) ),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Row(children: [
              Image.asset(
                icon, width: 35, height: 35,
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color )),
                    const SizedBox(height : Dimensions.paddingSizeExtraSmall),
                    Text( subTitle, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                  ],
                ),
              ),

            ]),
          ),
        ),
      );
    });
  }
}
