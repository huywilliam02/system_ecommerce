import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? info;
  final Color color;
  final Function onTap;
  const SupportButton({Key? key, required this.icon, required this.title, required this.info, required this.color, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap as void Function()?,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

          Container(
            height: 40, width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: color)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(info!, style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),

        ]),
      ),
    );
  }
}
