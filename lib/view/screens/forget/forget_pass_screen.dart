import 'package:country_code_picker/country_code_picker.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_delivery/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_delivery/util/images.dart';
import 'package:citgroupvn_ecommerce_delivery/util/styles.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_number/phone_number.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _numberController = TextEditingController();
  String? _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'forgot_password'.tr),
      body: SafeArea(child: Center(child: Scrollbar(child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Center(child: SizedBox(width: 1170, child: Column(children: [

          Image.asset(Images.forgot, height: 220),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Text('please_enter_mobile'.tr, style: robotoRegular, textAlign: TextAlign.center),
          ),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              color: Theme.of(context).cardColor,
            ),
            child: Row(children: [
              CountryCodePicker(
                onChanged: (CountryCode countryCode) {
                  _countryDialCode = countryCode.dialCode;
                },
                initialSelection: _countryDialCode,
                favorite: [_countryDialCode!],
                showDropDownButton: true,
                padding: EdgeInsets.zero,
                showFlagMain: true,
                textStyle: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              Expanded(child: CustomTextField(
                controller: _numberController,
                inputType: TextInputType.phone,
                inputAction: TextInputAction.done,
                hintText: 'phone'.tr,
                onSubmit: (text) => GetPlatform.isWeb ? _forgetPass(_countryDialCode!) : null,
              )),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          GetBuilder<AuthController>(builder: (authController) {
            return !authController.isLoading ? CustomButton(
              buttonText: 'next'.tr,
              onPressed: () => _forgetPass(_countryDialCode!),
            ) : const Center(child: CircularProgressIndicator());
          }),

        ]))),
      )))),
    );
  }

  void _forgetPass(String countryCode) async {
    String phone = _numberController.text.trim();

    String numberWithCountryCode = countryCode+phone;
    bool isValid = false;
    try {
      PhoneNumber phoneNumber = await PhoneNumberUtil().parse(numberWithCountryCode);
      numberWithCountryCode = '+${phoneNumber.countryCode}${phoneNumber.nationalNumber}';
      isValid = true;
    }catch(_) {}

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else {
      Get.find<AuthController>().forgetPassword(numberWithCountryCode).then((status) async {
        if (status.isSuccess) {
          Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode));
        }else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}