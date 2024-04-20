import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final String? image;
  const TitleWidget({Key? key, required this.title, this.onTap, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Text(title, style: robotoBold.copyWith(fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeLarge : Dimensions.fontSizeLarge)),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        image != null ? Image.asset(image!, height: 20, width: 20) : const SizedBox(),
        ],
      ),
      (onTap != null /*&& ResponsiveHelper.isDesktop(context)*/) ? InkWell(
        onTap: onTap as void Function()?,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
          child: Text(
            'see_all'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor, decoration: TextDecoration.underline),
          ),
        ),
      ) : const SizedBox(),
    ]);
  }
}
