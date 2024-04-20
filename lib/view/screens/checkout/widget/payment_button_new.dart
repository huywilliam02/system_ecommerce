import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentButtonNew extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final Function onTap;
  const PaymentButtonNew({Key? key, required this.isSelected, required this.icon, required this.title, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: InkWell(
          onTap: onTap as void Function()?,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.5))
                ),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                child: Row(children: [
                  Image.asset(
                    icon, width: 20, height: 20,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Text(
                      title,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                  ),
                ]),

              ),

              isSelected ? Positioned(top: -7, right: -7, child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              )) : const SizedBox(),
            ],
          ),
        ),
      );
    });
  }
}
