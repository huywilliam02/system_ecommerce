import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConditionCheckBox extends StatelessWidget {
  final AuthController authController;
  final bool fromSignUp;
  const ConditionCheckBox(
      {Key? key, required this.authController, this.fromSignUp = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment:
            fromSignUp ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          fromSignUp
              ? Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  value: authController.acceptTerms,
                  onChanged: (bool? isChecked) => authController.toggleTerms(),
                )
              : const SizedBox(),
          fromSignUp
              ? const SizedBox()
              : Text('* ',
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor)),
          Text(
              fromSignUp
                  ? 'i_agree_with_all_the'.tr
                  : 'by_login_i_agree_with_all_the'.tr,
              style: robotoRegular.copyWith(
                  color: fromSignUp
                      ? Theme.of(context).textTheme.bodyMedium!.color
                      : Theme.of(context).hintColor,
                  fontSize: fromSignUp
                      ? Dimensions.fontSizeDefault
                      : Dimensions.fontSizeSmall)),
          Expanded(
              child: InkWell(
            onTap: () =>
                Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Text('terms_conditions'.tr,
                  style: robotoMedium.copyWith(
                      fontSize: 12, color: Theme.of(context).primaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          )),
        ]);
  }
}
