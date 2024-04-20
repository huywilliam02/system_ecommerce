import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/view/screens/support/widget/support_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/screens/support/widget/web_help_support_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

// WebScreenTitleWidget(title: 'help_support'.tr),

class _SupportScreenState extends State<SupportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'help_support'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: Scrollbar(child: SingleChildScrollView(
        padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.all(Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        child: Center(child: FooterView(
          child: ResponsiveHelper.isDesktop(context) ? const SizedBox( width: double.infinity, height: 650, child: WebSupportScreen())
              :
          SizedBox(width: Dimensions.webMaxWidth, child: Column(children: [
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Image.asset(Images.supportImage, height: 120),
            const SizedBox(height: 30),

            Image.asset(Images.logo, width: 200),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            /*Text(AppConstants.APP_NAME, style: robotoBold.copyWith(
              fontSize: 20, color: Theme.of(context).primaryColor,
            )),*/
            const SizedBox(height: 30),

            SupportButton(
              icon: Icons.location_on, title: 'address'.tr, color: Colors.blue,
              info: Get.find<SplashController>().configModel!.address,
              onTap: () {},
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            SupportButton(
              icon: Icons.call, title: 'call'.tr, color: Colors.red,
              info: Get.find<SplashController>().configModel!.phone,
              onTap: () async {
                if(await canLaunchUrlString('tel:${Get.find<SplashController>().configModel!.phone}')) {
                  launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}');
                }else {
                  showCustomSnackBar('${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}');
                }
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            SupportButton(
              icon: Icons.mail_outline, title: 'email_us'.tr, color: Colors.green,
              info: Get.find<SplashController>().configModel!.email,
              onTap: () {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: Get.find<SplashController>().configModel!.email,
                );
                launchUrlString(emailLaunchUri.toString());
              },
            ),

          ])),
        )),
      )),
    );
  }
}
