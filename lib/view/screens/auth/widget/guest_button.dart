import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GuestButton extends StatelessWidget {
  const GuestButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return !authController.guestLoading ? TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(1, 40),
          ),
          onPressed: () {
            authController.guestLogin().then((response) {
              if(response.isSuccess) {
                Navigator.pushReplacementNamed(context, RouteHelper.getInitialRoute());
              }
            });
          },
          child: RichText(text: TextSpan(children: [
            TextSpan(text: '${'continue_as'.tr} ', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
            TextSpan(text: 'guest'.tr, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
          ])),
        ) : const Center(child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()));
      }
    );
  }
}
