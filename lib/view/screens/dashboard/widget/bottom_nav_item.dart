import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/theme_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';

class BottomNavItem extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Function? onTap;
  final bool isSelected;
  const BottomNavItem({Key? key, required this.iconData, this.onTap, this.isSelected = false, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          Icon(iconData,
            color: isSelected ? Theme.of(context).cardColor
                : Colors.white54,
            size: 25,
          ),
          SizedBox(height: isSelected ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall),

          isSelected ? Text(
            title,
            style: robotoRegular.copyWith(color: isSelected ? Theme.of(context).cardColor : Theme.of(context).disabledColor.withOpacity(0.8), fontSize: 12),
          ): const SizedBox(),
          ],
        ),
      ),
    );
  }
}
