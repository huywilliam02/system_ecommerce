import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/screens/wallet/widget/add_fund_dialogue.dart';
import 'package:citgroupvn_ecommerce/view/screens/wallet/widget/wallet_bottom_sheet.dart';

class WalletCardWidget extends StatelessWidget {
  final bool fromWallet;
  final JustTheController tooltipController;
  const WalletCardWidget({Key? key, required this.fromWallet, required this.tooltipController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (userController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Container(
                padding: EdgeInsets.all( ResponsiveHelper.isDesktop(context) ? 35 : Dimensions.paddingSizeExtraLarge),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: fromWallet ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.2),
                ),
                child:  Row(mainAxisAlignment: fromWallet ? MainAxisAlignment.start : MainAxisAlignment.center, children: [

                  !fromWallet ? Image.asset(Images.loyal , height: 60, width: 60, color: fromWallet ? Theme.of(context).cardColor : null) : const SizedBox(),
                  SizedBox(width: !fromWallet ? Dimensions.paddingSizeExtraLarge : 0),

                  fromWallet ? Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text('wallet_amount'.tr,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(children: [
                      Text(
                        PriceConverter.convertPrice(userController.userInfoModel!.walletBalance), textDirection: TextDirection.ltr,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).cardColor),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Get.find<SplashController>().configModel!.addFundStatus! ? JustTheTooltip(
                        backgroundColor: Colors.black87,
                        controller: tooltipController,
                        preferredDirection: AxisDirection.right,
                        tailLength: 14,
                        tailBaseWidth: 20,
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'if_you_want_to_add_fund_to_your_wallet_then_click_add_fund_button'.tr,
                            style: robotoRegular.copyWith(color: Colors.white),
                          ),
                        ),
                        child: InkWell(
                          onTap: () => tooltipController.showTooltip(),
                          child: Icon(Icons.info_outline, color: Theme.of(context).cardColor),
                        ),
                      ) : const SizedBox(),
                    ]),
                  ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                    ResponsiveHelper.isDesktop(context) ? const SizedBox() : Text(
                      '${'loyalty_points'.tr} !',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),

                    Text(
                      userController.userInfoModel!.loyaltyPoint == null ? '0' : userController.userInfoModel!.loyaltyPoint.toString(),
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),

                    ResponsiveHelper.isDesktop(context) ? Text(
                      '${'loyalty_points'.tr} !',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                    ) : const SizedBox(),

                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ])
                ]),
              ),

              fromWallet && Get.find<SplashController>().configModel!.addFundStatus! ? Positioned(
                top: 30, right: Get.find<LocalizationController>().isLtr ? 20 : null,
                left: Get.find<LocalizationController>().isLtr ? null : 10,
                child: InkWell(
                  onTap: () {
                    Get.dialog(
                      const Dialog(backgroundColor: Colors.transparent, child: SizedBox(width: 500, child: SingleChildScrollView(child: AddFundDialogue()))),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    child: const Icon(Icons.add),
                  ),
                ),
              ) : const SizedBox(),

            ]),
            ResponsiveHelper.isDesktop(context) ? const SizedBox() : const SizedBox(height: Dimensions.paddingSizeLarge),
            ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? Text('how_to_use'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)) : const SizedBox(),
            ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),

            !ResponsiveHelper.isDesktop(context) ? const SizedBox() : fromWallet ? const WalletStepper() : LoyalityStepper(fromWallet: fromWallet),
          ],
        );
      }
    );
  }
}



class LoyalityStepper extends StatelessWidget {
  final bool fromWallet;
  const LoyalityStepper({Key? key, required this.fromWallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).primaryColor, width: 2)
                    ),
                  ),

                  Expanded(
                    child: VerticalDivider(
                      thickness: 3,
                      color: Theme.of(context).primaryColor.withOpacity(0.30),
                    ),
                  ),

                  Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).primaryColor, width: 2)
                    ),
                  ),
                ],
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('convert_your_loyalty_point_to_wallet_money'.tr, style: robotoRegular),
                    Text('${'minimun'.tr} ${Get.find<SplashController>().configModel!.loyaltyPointExchangeRate} ${'points_required_to_convert_into_currency'.tr}', style: robotoRegular),
                  ],
                ),
              ),

            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        CustomButton(
          radius: Dimensions.radiusSmall,
          isBold: true,
          buttonText: 'convert_to_currency_now'.tr,
          onPressed: () {
            Get.dialog(
              Dialog(backgroundColor: Colors.transparent, child: WalletBottomSheet(
                fromWallet: fromWallet, amount: Get.find<UserController>().userInfoModel!.loyaltyPoint == null
                  ? '0' : Get.find<UserController>().userInfoModel!.loyaltyPoint.toString(),
              )),
            );
          },
        ),
      ],
    );
  }
}

class WalletStepper extends StatelessWidget {
  const WalletStepper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2)
                ),
              ),

              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Theme.of(context).primaryColor.withOpacity(0.30),
                ),
              ),

              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2)
                ),
              ),

              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Theme.of(context).primaryColor.withOpacity(0.30),
                ),
              ),

              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2)
                ),
              ),

              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: Theme.of(context).primaryColor.withOpacity(0.30),
                ),
              ),

              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2)
                ),
              ),
            ],
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('earn_money_to_your_wallet_by_completing_the_offer_challenged'.tr, style: robotoRegular),
                Text('convert_your_loyalty_points_into_wallet_money'.tr, style: robotoRegular),
                Text('amin_also_reward_their_top_customers_with_wallet_money'.tr, style: robotoRegular),
                Text('send_your_wallet_money_while_order'.tr, style: robotoRegular),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

