import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/theme_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/confirmation_dialog.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/screens/profile/widget/profile_button.dart';
import 'package:citgroupvn_ecommerce/view/screens/profile/widget/profile_card.dart';

class WebProfileWidget extends StatelessWidget {
  const WebProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController> (
      builder: (userController) {
        bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
        return SizedBox(
          width: Dimensions.webMaxWidth,
          child: Column(children : [
              SizedBox(
                height: 243,
                child: Stack(
                  children: [
                    Container(
                      height: 162,
                      width: Dimensions.webMaxWidth,
                      color: Theme.of(context).primaryColor.withOpacity(0.10),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                          child: Text('profile'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)))),
                    ),

                    Positioned(
                      top: 96,
                      left: (Dimensions.webMaxWidth/2) - 60,
                      child: ClipOval(child: CustomImage(
                        placeholder: Images.guestIcon,
                        image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                            '/${(userController.userInfoModel != null && isLoggedIn) ? userController.userInfoModel!.image : ''}',
                        height: 120, width: 120, fit: BoxFit.cover,
                    ))),

                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          isLoggedIn ? '${userController.userInfoModel!.fName} ${userController.userInfoModel!.lName}' : 'guest_user'.tr,
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                    ))),

                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: (){
                            Get.dialog(ConfirmationDialog(icon: Images.support,
                              title: 'are_you_sure_to_delete_account'.tr,
                              description: 'it_will_remove_your_all_information'.tr, isLogOut: true,
                              onYesPressed: () => userController.removeUser(),
                            ), useSafeArea: false);
                          },
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Image.asset(Images.profileDelete, height: 20, width: 20),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Text('delete_account'.tr , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                            ],
                          ))),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                const SizedBox( width: Dimensions.paddingSizeLarge),
                Expanded(
                  child: Container(
                    height: ResponsiveHelper.isDesktop(context) ? 130 :112,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).primaryColor, width: 0.1),
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ClipOval(child: CustomImage(
                        placeholder: Images.guestIcon,
                        image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                            '/${(userController.userInfoModel != null && isLoggedIn) ? userController.userInfoModel!.image : ''}',
                        height: 30, width: 30, fit: BoxFit.cover,
                      )),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Text(
                        DateConverter.containTAndZToUTCFormat(userController.userInfoModel!.createdAt!), textDirection: TextDirection.ltr,
                        style: robotoMedium.copyWith(fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeDefault : Dimensions.fontSizeExtraLarge),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text('since_joining'.tr, style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                      )),
                    ]),
                  ),
                ),


                // Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? Expanded(child: ProfileCard(
                //   image: Images.walletProfile,
                //   data: DateConverter.containTAndZToUTCFormat(userController.userInfoModel!.createdAt!),
                //   title: 'since_joining'.tr,
                // )) : const SizedBox(),
                const SizedBox( width: Dimensions.paddingSizeExtremeLarge),
                //SizedBox(width: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? Dimensions.paddingSizeSmall : 0),

                Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? Expanded(child: ProfileCard(
                  image: Images.walletProfile,
                  data: PriceConverter.convertPrice(userController.userInfoModel!.walletBalance),
                  title: 'wallet_balance'.tr,
                )) : const SizedBox(),
                SizedBox(width: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? Dimensions.paddingSizeExtremeLarge : 0),

                isLoggedIn ?  Expanded(child: ProfileCard(
                    image: Images.shoppingBagIcon,
                    data: userController.userInfoModel!.orderCount.toString(),
                    title: 'total_order'.tr,
                  )) : const SizedBox(),
                  SizedBox(width: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? Dimensions.paddingSizeExtremeLarge : 0),

                Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 ? Expanded(child: ProfileCard(
                  image: Images.loyaltyIcon,
                  data: userController.userInfoModel!.loyaltyPoint != null ? userController.userInfoModel!.loyaltyPoint.toString() : '0',
                  title: 'loyalty_points'.tr,
                )) : const SizedBox(),
                SizedBox(width: Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 ? Dimensions.paddingSizeLarge : 0),
                ],
              ),
            const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

            GridView.count(
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              childAspectRatio: 9,
              children: <Widget>[

                ProfileButton(icon: Icons.tonality_outlined, title: 'dark_mode'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                  Get.find<ThemeController>().toggleTheme();
                }),

                isLoggedIn ? GetBuilder<AuthController>(builder: (authController) {
                  return ProfileButton(
                    icon: Icons.notifications, title: 'notification'.tr,
                    isButtonActive: authController.notification, onTap: () {
                    authController.setNotificationActive(!authController.notification);
                  },
                  );
                }) : const SizedBox(),

                isLoggedIn ? userController.userInfoModel!.socialId == null ? ProfileButton(icon: Icons.lock, title: 'change_password'.tr, onTap: () {
                  Get.toNamed(RouteHelper.getResetPasswordRoute('', '', 'password-change'));
                }) : const SizedBox() : const SizedBox(),

                isLoggedIn ? ProfileButton(icon: Icons.edit, title: 'edit_profile'.tr, onTap: () {
                  Get.toNamed(RouteHelper.getUpdateProfileRoute());
                }) : const SizedBox(),

              ],
            ),
            const SizedBox( height: 100)

            ]
          ),
        );
      }
    );
  }
}
