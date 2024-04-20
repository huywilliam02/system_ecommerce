import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
class DeliveryDetails extends StatelessWidget {
  final bool from;
  final String? address;
  const DeliveryDetails({Key? key, this.from = true, this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Icon(from ? Icons.store : Icons.location_on, size: 28, color: from ? Colors.blue : Theme.of(context).primaryColor),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(from ? 'from_store'.tr : 'to'.tr, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(
          address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
        )
      ])),
    ]);
  }
}
