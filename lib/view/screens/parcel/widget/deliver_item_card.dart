import 'package:flutter/material.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';

class DeliverItemCard extends StatelessWidget {
  final String image;
  final String itemName;
  final String description;
  final bool isDeliverItem;
  const DeliverItemCard({Key? key, required this.image, required this.itemName, required this.description, this.isDeliverItem = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: isDeliverItem ? Theme.of(context).primaryColor.withOpacity(0.05) : Theme.of(context).cardColor.withOpacity(0.5),
        border: Border.all(color: isDeliverItem ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomImage(
            image: image,
            height: 30, width: 30,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: ResponsiveHelper.isDesktop(context) ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween, children: [
                Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium),
                SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

                Text(
                  description,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
