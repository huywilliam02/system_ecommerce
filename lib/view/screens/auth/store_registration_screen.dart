import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce_store/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/data/model/body/store_body.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/config_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce_store/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_store/util/styles.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_text_field.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/auth/widget/custom_time_picker.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/auth/widget/pass_view.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/auth/widget/select_location_module_view.dart';

class StoreRegistrationScreen extends StatefulWidget {
  const StoreRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<StoreRegistrationScreen> createState() => _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> {
  final List<TextEditingController> _nameController = [];
  final List<TextEditingController> _addressController = [];
  final TextEditingController _vatController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final List<FocusNode> _nameFocus = [];
  final List<FocusNode> _addressFocus = [];
  final FocusNode _vatFocus = FocusNode();
  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final List<Language>? _languageList = Get.find<SplashController>().configModel!.language;

  String? _countryDialCode;
  bool firstTime = true;

  @override
  void initState() {
    super.initState();

    // Get.find<SplashController>().getModules();
    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    for (var language in _languageList!) {
      if (kDebugMode) {
        print(language);
      }
      _nameController.add(TextEditingController());
      _addressController.add(TextEditingController());
      _nameFocus.add(FocusNode());
      _addressFocus.add(FocusNode());
    }
    Get.find<AuthController>().storeStatusChange(0.4, isUpdate: false);
    Get.find<AuthController>().getZoneList();
    Get.find<AuthController>().setDeliveryTimeTypeIndex(Get.find<AuthController>().deliveryTimeTypeList[0], false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'store_registration'.tr),
      body: GetBuilder<AuthController>(builder: (authController) {
        if(authController.storeAddress != null && _languageList!.isNotEmpty){
          _addressController[0].text = authController.storeAddress.toString();
        }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical:  Dimensions.paddingSizeSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  authController.storeStatus == 0.4 ? 'provide_store_information_to_proceed_next'.tr : 'provide_owner_information_to_confirm'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                LinearProgressIndicator(
                  backgroundColor: Theme.of(context).disabledColor, minHeight: 2,
                  value: authController.storeStatus,
                ),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                child: Column(children: [

                  Visibility(
                    visible: authController.storeStatus == 0.4,
                    child: Column(children: [

                      Row(children: [
                        Expanded(flex: 4, child:  Align(alignment: Alignment.center, child: Stack(children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: authController.pickedLogo != null ? Image.file(
                                File(authController.pickedLogo!.path), width: 150, height: 120, fit: BoxFit.cover,
                              ) : SizedBox(
                                width: 150, height: 120,
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                                  Icon(Icons.camera_alt, size: 38, color: Theme.of(context).disabledColor),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),

                                  Text(
                                    'upload_store_logo'.tr,
                                    style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), textAlign: TextAlign.center,
                                  ),
                                ]),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0, top: 0, left: 0,
                            child: InkWell(
                              onTap: () => authController.pickImageForReg(true, false),
                              child: DottedBorder(
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 1,
                                strokeCap: StrokeCap.butt,
                                dashPattern: const [5, 5],
                                padding: const EdgeInsets.all(0),
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(Dimensions.radiusDefault),
                                child: Center(
                                  child: Visibility(
                                    visible: authController.pickedLogo != null,
                                    child: Container(
                                      padding: const EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 2, color: Colors.white),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ])),),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(flex: 6, child: Stack(children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: authController.pickedCover != null ? GetPlatform.isWeb ? Image.network(
                                authController.pickedCover!.path, width: context.width, height: 120, fit: BoxFit.cover,
                              ) : Image.file(
                                File(authController.pickedCover!.path), width: context.width, height: 120, fit: BoxFit.cover,
                              ) : SizedBox(
                                width: context.width, height: 120,
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                                  Icon(Icons.camera_alt, size: 38, color: Theme.of(context).disabledColor),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),

                                  Text(
                                    'upload_store_cover'.tr,
                                    style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), textAlign: TextAlign.center,
                                  ),
                                ]),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0, top: 0, left: 0,
                            child: InkWell(
                              onTap: () => authController.pickImageForReg(false, false),
                              child: DottedBorder(
                                color: Theme.of(context).primaryColor,
                                strokeWidth: 1,
                                strokeCap: StrokeCap.butt,
                                dashPattern: const [5, 5],
                                padding: const EdgeInsets.all(0),
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(Dimensions.radiusDefault),
                                child: Center(
                                  child: Visibility(
                                    visible: authController.pickedCover != null,
                                    child: Container(
                                      padding: const EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 3, color: Colors.white),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 50),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      ListView.builder(
                          itemCount: _languageList!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraLarge),
                              child: CustomTextField(
                                hintText: '${'store_name'.tr} (${_languageList![index].value!})',
                                controller: _nameController[index],
                                focusNode: _nameFocus[index],
                                nextFocus: index != _languageList!.length-1 ? _nameFocus[index+1] : _addressFocus[0],
                                inputType: TextInputType.name,
                                capitalization: TextCapitalization.words,
                              ),
                            );
                          }
                      ),

                      authController.zoneList != null ? const SelectLocationAndModuleView(fromView: true) : const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      ListView.builder(
                          itemCount: _languageList!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraLarge),
                              child: CustomTextField(
                                hintText: '${'store_address'.tr} (${_languageList![index].value!})',
                                controller: _addressController[index],
                                focusNode: _addressFocus[index],
                                nextFocus: index != _languageList!.length-1 ? _addressFocus[index+1] : _vatFocus,
                                inputType: TextInputType.text,
                                capitalization: TextCapitalization.sentences,
                                maxLines: 3,
                              ),
                            );
                          }
                      ),

                      CustomTextField(
                        hintText: 'vat_tax'.tr,
                        controller: _vatController,
                        focusNode: _vatFocus,
                        inputAction: TextInputAction.done,
                        inputType: TextInputType.number,
                        isAmount: true,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      InkWell(
                        onTap: () {
                          Get.dialog(const CustomTimePicker());
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                          child: Row(children: [
                            Expanded(child: Text(
                              '${authController.storeMinTime} : ${authController.storeMaxTime} ${authController.storeTimeUnit}',
                              style: robotoMedium,
                            )),
                            Icon(Icons.access_time_filled, color: Theme.of(context).primaryColor,)
                          ]),
                        ),
                      )

                    ]),
                  ),

                  Visibility(
                    visible: authController.storeStatus != 0.4,
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                      Row(children: [
                        Expanded(child: CustomTextField(
                          hintText: 'first_name'.tr,
                          controller: _fNameController,
                          focusNode: _fNameFocus,
                          nextFocus: _lNameFocus,
                          inputType: TextInputType.name,
                          capitalization: TextCapitalization.words,
                        )),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(child: CustomTextField(
                          hintText: 'last_name'.tr,
                          controller: _lNameController,
                          focusNode: _lNameFocus,
                          nextFocus: _phoneFocus,
                          inputType: TextInputType.name,
                          capitalization: TextCapitalization.words,
                        )),
                      ]),

                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      CustomTextField(
                        hintText: 'enter_phone_number'.tr,
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        nextFocus: _emailFocus,
                        inputType: TextInputType.phone,
                        isPhone: true,
                        showTitle: false,
                        onCountryChanged: (CountryCode countryCode) {
                          _countryDialCode = countryCode.dialCode;
                        },
                        countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                            : Get.find<LocalizationController>().locale.countryCode,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      CustomTextField(
                        hintText: 'email'.tr,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        nextFocus: _passwordFocus,
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      CustomTextField(
                        hintText: 'password'.tr,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        nextFocus: _confirmPasswordFocus,
                        inputType: TextInputType.visiblePassword,
                        isPassword: true,
                        onChanged: (value){
                          if(value != null && value.isNotEmpty){
                            if(!authController.showPassView){
                              authController.showHidePass();
                            }
                            authController.validPassCheck(value);
                          }else{
                            if(authController.showPassView){
                              authController.showHidePass();
                            }
                          }
                        },
                      ),
                      authController.showPassView ? const PassView() : const SizedBox(),

                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      CustomTextField(
                        hintText: 'confirm_password'.tr,
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        inputType: TextInputType.visiblePassword,
                        inputAction: TextInputAction.done,
                        isPassword: true,
                      ),

                    ]),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            !authController.isLoading ? CustomButton(
              buttonText: 'submit'.tr,
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              onPressed: () {
                bool defaultNameNull = false;
                bool defaultAddressNull = false;
                for(int index=0; index<_languageList!.length; index++) {
                  if(_languageList![index].key == 'en') {
                    if (_nameController[index].text.trim().isEmpty) {
                      defaultNameNull = true;
                    }
                    if(_addressController[index].text.trim().isEmpty){
                      defaultAddressNull = true;
                    }
                    break;
                  }
                }
                String vat = _vatController.text.trim();
                String minTime = authController.storeMinTime;
                String maxTime = authController.storeMaxTime;
                String fName = _fNameController.text.trim();
                String lName = _lNameController.text.trim();
                String phone = _phoneController.text.trim();
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                String confirmPassword = _confirmPasswordController.text.trim();
                bool valid = false;
                try {
                  double.parse(maxTime);
                  double.parse(minTime);
                  valid = true;
                } on FormatException {
                  valid = false;
                }
                if(authController.storeStatus == 0.4){
                  if(defaultNameNull) {
                    showCustomSnackBar('enter_store_name'.tr);
                  }else if(authController.selectedModuleIndex == -1) {
                    showCustomSnackBar('please_select_module_first'.tr);
                  }else if(defaultAddressNull) {
                    showCustomSnackBar('enter_store_address'.tr);
                  }else if(authController.selectedZoneIndex == -1) {
                    showCustomSnackBar('please_select_zone'.tr);
                  }else if(vat.isEmpty) {
                    showCustomSnackBar('enter_vat_amount'.tr);
                  }else if(minTime.isEmpty) {
                    showCustomSnackBar('enter_minimum_delivery_time'.tr);
                  }else if(maxTime.isEmpty) {
                    showCustomSnackBar('enter_maximum_delivery_time'.tr);
                  }else if(!valid) {
                    showCustomSnackBar('please_enter_the_max_min_delivery_time'.tr);
                  }else if(valid && double.parse(minTime) > double.parse(maxTime)) {
                    showCustomSnackBar('maximum_delivery_time_can_not_be_smaller_then_minimum_delivery_time'.tr);
                  }else if(authController.pickedLogo == null) {
                    showCustomSnackBar('select_store_logo'.tr);
                  }else if(authController.pickedCover == null) {
                    showCustomSnackBar('select_store_cover_photo'.tr);
                  }else if(authController.restaurantLocation == null) {
                    showCustomSnackBar('set_store_location'.tr);
                  }else{
                    authController.storeStatusChange(0.8);
                    firstTime = true;
                  }
                }else{
                  if(fName.isEmpty) {
                    showCustomSnackBar('enter_your_first_name'.tr);
                  }else if(lName.isEmpty) {
                    showCustomSnackBar('enter_your_last_name'.tr);
                  }else if(phone.isEmpty) {
                    showCustomSnackBar('enter_phone_number'.tr);
                  }else if(email.isEmpty) {
                    showCustomSnackBar('enter_email_address'.tr);
                  }else if(!GetUtils.isEmail(email)) {
                    showCustomSnackBar('enter_a_valid_email_address'.tr);
                  }else if(password.isEmpty) {
                    showCustomSnackBar('enter_password'.tr);
                  }else if(password.length < 6) {
                    showCustomSnackBar('password_should_be'.tr);
                  }else if(password != confirmPassword) {
                    showCustomSnackBar('confirm_password_does_not_matched'.tr);
                  }else {
                    List<Translation> translation = [];
                    for(int index=0; index<_languageList!.length; index++) {
                      translation.add(Translation(
                        locale: _languageList![index].key, key: 'name',
                        value: _nameController[index].text.trim().isNotEmpty ? _nameController[index].text.trim()
                            : _nameController[0].text.trim(),
                      ));
                      translation.add(Translation(
                        locale: _languageList![index].key, key: 'address',
                        value: _addressController[index].text.trim().isNotEmpty ? _addressController[index].text.trim()
                            : _addressController[0].text.trim(),
                      ));
                    }
                    authController.registerStore(StoreBody(
                      translation: jsonEncode(translation), tax: vat, minDeliveryTime: minTime,
                      maxDeliveryTime: maxTime, lat: authController.restaurantLocation!.latitude.toString(), email: email,
                      lng: authController.restaurantLocation!.longitude.toString(), fName: fName, lName: lName, phone: phone,
                      password: password, zoneId: authController.zoneList![authController.selectedZoneIndex!].id.toString(),
                      moduleId: authController.moduleList![authController.selectedModuleIndex!].id.toString(),
                      deliveryTimeType: authController.deliveryTimeTypeList[authController.deliveryTimeTypeIndex],
                    ));
                  }
                }
              },
            ) : const Center(child: CircularProgressIndicator()),

          ]);
        }),
    );
  }

}
