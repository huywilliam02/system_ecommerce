import 'package:citgroupvn_ecommerce_delivery/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CountCard extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String? value;
  final double height;
  const CountCard({Key? key, required this.backgroundColor, required this.title, required this.value, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height, width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

        value != null ? Text(
          value!, style: robotoBold.copyWith(fontSize: 40, color: Colors.white), textAlign: TextAlign.center,
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ) : Shimmer(
          duration: const Duration(seconds: 2),
          enabled: value == null,
          color: Colors.grey[500]!,
          child: Container(height: 60, width: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Text(
          title,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.white),
          textAlign: TextAlign.center,
        ),

      ]),
    );
  }
}