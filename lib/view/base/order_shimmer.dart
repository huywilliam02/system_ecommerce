import 'package:citgroupvn_ecommerce_delivery/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_delivery/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderShimmer extends StatelessWidget {
  final bool isEnabled;
  const OrderShimmer({Key? key, required this.isEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: isEnabled,
        child: Column(children: [

          Row(children: [
            Container(height: 15, width: 100, color: Colors.grey[300]),
            const Expanded(child: SizedBox()),
            Container(width: 7, height: 7, decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle)),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Container(height: 15, width: 70, color: Colors.grey[300]),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
            Image.asset(Images.house, width: 20, height: 15),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Container(height: 15, width: 200, color: Colors.grey[300]),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
            const Icon(Icons.location_on, size: 20),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Container(height: 15, width: 200, color: Colors.grey[300]),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(children: [
            Expanded(child: Container(height: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(5)))),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: Container(height: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(5)))),
          ]),

        ]),
      ),
    );
  }
}
