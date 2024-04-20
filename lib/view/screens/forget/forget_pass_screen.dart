import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/body/social_log_in_body.dart';
import 'package:citgroupvn_ecommerce/helper/custom_validator.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_text_field.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  final bool fromSocialLogin;
  final SocialLogInBody? socialLogInBody;
  const ForgetPassScreen({Key? key, required this.fromSocialLogin, required this.socialLogInBody}) : super(key: key);

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _numberController = TextEditingController();
  String? _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.fromSocialLogin ? 'phone'.tr : 'forgot_password'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(child: Center(child: Scrollbar(child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FooterView(child: Container(
          width: context.width > 700 ? 700 : context.width,
          padding: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : const EdgeInsets.all(Dimensions.paddingSizeLarge),
          margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: context.width > 700 ? BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
          ) : null,
          child: Column(children: [

            Image.asset(Images.forgot, height: 220),

            Padding(
              padding: const EdgeInsets.all(30),
              child: Text('please_enter_mobile'.tr, style: robotoRegular, textAlign: TextAlign.center),
            ),

            CustomTextField(
              titleText: 'phone'.tr,
              controller: _numberController,
              inputType: TextInputType.phone,
              inputAction: TextInputAction.done,
              isPhone: true,
              showTitle: ResponsiveHelper.isDesktop(context),
              onCountryChanged: (CountryCode countryCode) {
                _countryDialCode = countryCode.dialCode;
              },
              countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                  : Get.find<LocalizationController>().locale.countryCode,
              onSubmit: (text) => GetPlatform.isWeb ? _forgetPass(_countryDialCode!) : null,
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            GetBuilder<AuthController>(builder: (authController) {
              return CustomButton(
                buttonText: 'next'.tr,
                isLoading: authController.isLoading,
                onPressed: () => _forgetPass(_countryDialCode!),
              );
            }),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            RichText(text: TextSpan(children: [
              TextSpan(
                text: '${'if_you_have_any_queries_feel_free_to_contact_with_our'.tr} ',
                style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
              ),
              TextSpan(
                text: 'help_and_support'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.toNamed(RouteHelper.getSupportRoute()),
              ),
            ]), textAlign: TextAlign.center, maxLines: 3),

          ]),
        )),
      )))),
    );
  }

  void _forgetPass(String countryCode) async {
    String phone = _numberController.text.trim();

    String numberWithCountryCode = countryCode+phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else {
      if(widget.fromSocialLogin) {
        widget.socialLogInBody!.phone = numberWithCountryCode;
        Get.find<AuthController>().registerWithSocialMedia(widget.socialLogInBody!);
      }else {
        Get.find<AuthController>().forgetPassword(numberWithCountryCode).then((status) async {
          if (status.isSuccess) {
            Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode, '', RouteHelper.forgotPassword, ''));
          }else {
            showCustomSnackBar(status.message);
          }
        });
      }
    }
  }
}
