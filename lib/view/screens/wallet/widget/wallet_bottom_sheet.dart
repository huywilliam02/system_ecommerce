
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/controller/wallet_controller.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_text_field.dart';

class WalletBottomSheet extends StatefulWidget {
  final bool fromWallet;
  final String amount;
  const WalletBottomSheet({Key? key, required this.fromWallet, required this.amount}) : super(key: key);

  @override
  State<WalletBottomSheet> createState() => _WalletBottomSheetState();
}

class _WalletBottomSheetState extends State<WalletBottomSheet> {

  final TextEditingController _amountController = TextEditingController();


  int? exchangePointRate = Get.find<SplashController>().configModel!.loyaltyPointExchangeRate ?? 0;
  int? minimumExchangePoint = Get.find<SplashController>().configModel!.minimumPointToTransfer ?? 0;

  @override
  void initState() {
    super.initState();

    if(widget.fromWallet){
      _amountController.text = '';
    }else {
      _amountController.text = exchangePointRate!.toString();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
          width: ResponsiveHelper.isDesktop(context) ? 400 : 550,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Image.asset(ResponsiveHelper.isDesktop(context) ? Images.loyaltyConvertIcon : Images.creditIcon, height: 50, width: 50),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              !widget.fromWallet ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '$exchangePointRate ${'points'.tr}= ',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                Text(
                  PriceConverter.convertPrice(1), textDirection: TextDirection.ltr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ]) : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              !widget.fromWallet ? Text(
                '(${'from'.tr} ${widget.amount} ${'points'.tr})',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              ) : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              !widget.fromWallet ? Text(
                'amount_can_be_convert_into_wallet_money'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              ) : Text(
                'add_fund_from_your_digital_account'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge :  Dimensions.paddingSizeLarge),

              SizedBox(
                width: ResponsiveHelper.isDesktop(context) ? 260 : null,
                child: CustomTextField(
                  titleText: 'enter_amount'.tr,
                  controller: _amountController,
                  inputType: TextInputType.phone,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox( height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeLarge),

              GetBuilder<WalletController>(builder: (walletController) {
                return CustomButton(
                      width: ResponsiveHelper.isDesktop(context) ? 136 : context.width/3, isBold: false,
                      buttonText: widget.fromWallet ? 'add_fund'.tr : 'convert'.tr, radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : 50,
                      isLoading: walletController.isLoading,
                      onPressed: () {
                        if(widget.fromWallet){

                        }else{
                          if(_amountController.text.isEmpty) {
                            if(Get.isBottomSheetOpen!){
                              Get.back();
                            }
                            showCustomSnackBar('input_field_is_empty'.tr);
                          }else{
                            int amount = int.parse(_amountController.text.trim());
                            int? point = Get.find<UserController>().userInfoModel!.loyaltyPoint;

                            if(amount <minimumExchangePoint!){
                              if(Get.isBottomSheetOpen!){
                                Get.back();
                              }
                              showCustomSnackBar('${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}');
                            }else if(point! < amount){
                              if(Get.isBottomSheetOpen!){
                                Get.back();
                              }
                              showCustomSnackBar('you_do_not_have_enough_point_to_exchange'.tr);
                            } else {
                              walletController.pointToWallet(amount, widget.fromWallet);
                            }
                          }
                        }

                      },
                    );
              }),
            ]),
          ),
        ),
        Positioned(
          top: 10, right: 10,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.clear, size: 18),
          ),
        ),
      ],
    );
  }
}
