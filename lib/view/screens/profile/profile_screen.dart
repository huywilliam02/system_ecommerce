import 'package:citgroupvn_ecommerce_store/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/theme_controller.dart';
import 'package:citgroupvn_ecommerce_store/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_store/util/app_constants.dart';
import 'package:citgroupvn_ecommerce_store/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_store/util/images.dart';
import 'package:citgroupvn_ecommerce_store/util/styles.dart';
import 'package:citgroupvn_ecommerce_store/view/base/confirmation_dialog.dart';
import 'package:citgroupvn_ecommerce_store/view/base/switch_button.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/profile/widget/profile_bg_widget.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/profile/widget/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isOwner;

  @override
  void initState() {
    super.initState();

    Get.find<AuthController>().getProfile();

    _isOwner = Get.find<AuthController>().getUserType() == 'owner';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<AuthController>(builder: (authController) {
        return authController.profileModel == null ? const Center(child: CircularProgressIndicator()) : ProfileBgWidget(
          backButton: true,
          circularImage: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Theme.of(context).cardColor),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: ClipOval(child: FadeInImage.assetNetwork(
              placeholder: Images.placeholder,
              image: _isOwner ? '${Get.find<SplashController>().configModel!.baseUrls!.vendorImageUrl}'
                  '/${authController.profileModel != null ? authController.profileModel!.image : ''}'
                  : '${Get.find<SplashController>().configModel!.baseUrls!.vendorImageUrl}/${authController.profileModel!.image}',
              height: 100, width: 100, fit: BoxFit.cover,
              imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 100, width: 100, fit: BoxFit.cover),
            )),
          ),
          mainWidget: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: Center(child: Container(
            width: 1170, color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(children: [

              _isOwner ? Text(
                '${authController.profileModel!.fName} ${authController.profileModel!.lName}',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ) : Text(
                '${authController.profileModel!.employeeInfo!.fName} ${authController.profileModel!.employeeInfo!.lName}',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: 30),

              Row(children: [
                _isOwner ? ProfileCard(title: 'since_joining'.tr, data: '${authController.profileModel!.memberSinceDays} ${'days'.tr}') : const SizedBox(),
                SizedBox(width: Get.find<AuthController>().modulePermission!.order! && _isOwner ? Dimensions.paddingSizeSmall : 0),
                Get.find<AuthController>().modulePermission!.order! ? ProfileCard(title: 'total_order'.tr, data: authController.profileModel!.orderCount.toString()) : const SizedBox(),
              ]),
              const SizedBox(height: 30),

              SwitchButton(icon: Icons.dark_mode, title: 'dark_mode'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                Get.find<ThemeController>().toggleTheme();
              }),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              SwitchButton(
                icon: Icons.notifications, title: 'notification'.tr,
                isButtonActive: authController.notification, onTap: () {
                  authController.setNotificationActive(!authController.notification);
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              _isOwner ? SwitchButton(icon: Icons.lock, title: 'change_password'.tr, onTap: () {
                Get.toNamed(RouteHelper.getResetPasswordRoute('', '', 'password-change'));
              }) : const SizedBox(),
              SizedBox(height: _isOwner ? Dimensions.paddingSizeSmall : 0),

              _isOwner ? SwitchButton(icon: Icons.edit, title: 'edit_profile'.tr, onTap: () {
                Get.toNamed(RouteHelper.getUpdateProfileRoute());
              }) : const SizedBox(),
              SizedBox(height: _isOwner ? Dimensions.paddingSizeSmall : 0),

              _isOwner ? SwitchButton(
                icon: Icons.delete, title: 'delete_account'.tr,
                onTap: () {
                  Get.dialog(ConfirmationDialog(icon: Images.warning, title: 'are_you_sure_to_delete_account'.tr,
                      description: 'it_will_remove_your_all_information'.tr, isLogOut: true,
                      onYesPressed: () => authController.removeVendor()),
                      useSafeArea: false);
                },
              ) : const SizedBox(),
              SizedBox(height: _isOwner ? Dimensions.paddingSizeLarge : 0),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${'version'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(AppConstants.appVersion.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
              ]),

            ]),
          ))),
        );
      }),
    );
  }
}