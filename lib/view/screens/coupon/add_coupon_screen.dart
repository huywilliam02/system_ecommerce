import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce_store/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/coupon_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/config_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/coupon_body.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce_store/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce_store/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_store/util/styles.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/my_text_field.dart';

class AddCouponScreen extends StatefulWidget {
  final CouponBody? coupon;
  const AddCouponScreen({Key? key, this.coupon}) : super(key: key);

  @override
  State<AddCouponScreen> createState() => _AddCouponScreenState();
}

class _AddCouponScreenState extends State<AddCouponScreen> {
  final List<TextEditingController> _titleController = [];
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _expireDateController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _maxDiscountController = TextEditingController();
  final TextEditingController _minPurchaseController = TextEditingController();

  final List<FocusNode> _titleNode = [];
  final FocusNode _codeNode = FocusNode();
  final FocusNode _limitNode = FocusNode();
  final FocusNode _minNode = FocusNode();
  final FocusNode _discountNode = FocusNode();
  final FocusNode _maxDiscountNode = FocusNode();
  final List<Language>? _languageList = Get.find<SplashController>().configModel!.language;

  @override
  void initState() {
    super.initState();
    if(widget.coupon != null){
      List<Translation> translation = widget.coupon!.translations!;
      int translationLength = translation.length;
      for(int index = 0; index<_languageList!.length; index++) {
        _titleController.add(TextEditingController(
          text: translation[index].value,
        ));
        _titleNode.add(FocusNode());
      }
      _codeController.text = widget.coupon!.code!;
      _limitController.text = widget.coupon!.limit.toString();
      _startDateController.text = widget.coupon!.startDate.toString();
      _expireDateController.text = widget.coupon!.expireDate.toString();
      _discountController.text = widget.coupon!.discount.toString();
      _maxDiscountController.text = widget.coupon!.maxDiscount.toString();
      _minPurchaseController.text = widget.coupon!.minPurchase.toString();
      Get.find<CouponController>().setCouponTypeIndex(widget.coupon!.couponType == 'default' ? 0 : 1 , false);
      Get.find<CouponController>().setDiscountTypeIndex(widget.coupon!.discountType == 'percent' ? 0 : 1, false);
    }else{
      for (var language in _languageList!) {
        if (kDebugMode) {
          print(language);
        }
        _titleController.add(TextEditingController());
        _titleNode.add(FocusNode());
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    late bool selfDelivery;
    if(Get.find<AuthController>().profileModel != null && Get.find<AuthController>().profileModel!.stores != null){
      selfDelivery = Get.find<AuthController>().profileModel!.stores![0].selfDeliverySystem == 1;
    }
    if(!selfDelivery){
      Get.find<CouponController>().setCouponTypeIndex(0, false);
    }
    return Scaffold(
      appBar: CustomAppBar(title: widget.coupon != null ? 'update_coupon'.tr : 'add_coupon'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
        child: GetBuilder<CouponController>(
          builder: (couponController) {
            return Column(children: [

              ListView.builder(
                itemCount: _languageList!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                    child: MyTextField(
                      hintText: '${'title'.tr} (${_languageList![index].value!})',
                      controller: _titleController[index],
                      focusNode: _titleNode[index],
                      nextFocus: index != _languageList!.length-1 ? _titleNode[index+1] : _codeNode,
                    ),
                  );
                }
              ),

              Row(children: [
                selfDelivery ? Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'coupon_type'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 5))],
                      ),
                      child: DropdownButton<String>(
                        value: couponController.couponTypeIndex == 0 ? 'default' : 'free_delivery',
                        items: <String>['default', 'free_delivery'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.tr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          couponController.setCouponTypeIndex(value == 'default' ? 0 : 1, true);
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    ),
                  ]),
                )  : const SizedBox(),
                SizedBox(width: selfDelivery ? Dimensions.paddingSizeSmall : 0),

                Expanded(child: MyTextField(
                  hintText: 'code'.tr,
                  controller: _codeController,
                  focusNode: _codeNode,
                  nextFocus: _limitNode,
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(children: [
                Expanded(child: MyTextField(
                  hintText: 'limit_for_same_user'.tr,
                  controller: _limitController,
                  focusNode: _limitNode,
                  nextFocus: _minNode,
                  isAmount: true,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: MyTextField(
                  hintText: 'min_purchase'.tr,
                  controller: _minPurchaseController,
                  isAmount: true,
                  focusNode: _minNode,
                  nextFocus: _discountNode,
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(children: [
                Expanded(child: MyTextField(
                  controller: _startDateController,
                  hintText: 'start_date'.tr,
                  readOnly: true,
                  onTap: () async{
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateConverter.dateTimeForCoupon(pickedDate);
                      setState(() {
                        _startDateController.text = formattedDate;
                      });
                    }
                  },
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: MyTextField(
                  controller: _expireDateController,
                  hintText: 'expire_date'.tr,
                  readOnly: true,
                  onTap: () async{
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateConverter.dateTimeForCoupon(pickedDate);
                      setState(() {
                        _expireDateController.text = formattedDate;
                      });
                    }
                  },
                )),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              couponController.couponTypeIndex == 0 ? Row(children: [
                Expanded(child: MyTextField(
                  hintText: 'discount'.tr,
                  controller: _discountController,
                  isAmount: true,
                  focusNode: _discountNode,
                  nextFocus: _maxDiscountNode,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'discount_type'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 5))],
                    ),
                    child: DropdownButton<String>(
                      value: couponController.discountTypeIndex == 0 ? 'percent' : 'amount',
                      items: <String>['percent', 'amount'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.tr),
                        );
                      }).toList(),
                      onChanged: (value) {
                        couponController.setDiscountTypeIndex(value == 'percent' ? 0 : 1, true);
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                    ),
                  ),
                ])),
              ]) : const SizedBox(),
              SizedBox(height: couponController.couponTypeIndex == 0 ? Dimensions.paddingSizeLarge : 0),

              couponController.couponTypeIndex == 0 && couponController.discountTypeIndex == 0 ?MyTextField(
                hintText: 'max_discount'.tr,
                controller: _maxDiscountController,
                isAmount: true,
                focusNode: _maxDiscountNode,
                inputAction: TextInputAction.done,
              ) : const SizedBox(),
              const SizedBox(height: 50),

              !couponController.isLoading ? CustomButton(
                buttonText: widget.coupon == null ? 'add'.tr : 'update'.tr,
                onPressed: (){
                  bool defaultNameNull = false;
                  for(int index=0; index<_languageList!.length; index++) {
                    if(_languageList![index].key == 'en') {
                      if (_titleController[index].text.trim().isEmpty) {
                        defaultNameNull = true;
                      }
                      break;
                    }
                  }
                  String code = _codeController.text.trim();
                  String startDate = _startDateController.text.trim();
                  String expireDate = _expireDateController.text.trim();
                  String discount = _discountController.text.trim();
                  if(defaultNameNull){
                    showCustomSnackBar('please_fill_up_your_coupon_title'.tr);
                  }else if(code.isEmpty){
                    showCustomSnackBar('please_fill_up_your_coupon_code'.tr);
                  }else if(startDate.isEmpty){
                    showCustomSnackBar('please_select_your_coupon_start_date'.tr);
                  }else if(expireDate.isEmpty){
                    showCustomSnackBar('please_select_your_coupon_expire_date'.tr);
                  }else if(couponController.couponTypeIndex == 0 && discount.isEmpty){
                    showCustomSnackBar('please_fill_up_your_coupon_discount'.tr);
                  }else if(couponController.couponTypeIndex == 0 && (int.parse(_limitController.text.trim()) > 100)){
                    showCustomSnackBar('limit_for_same_user_cant_be_more_then_100'.tr);
                  }else {
                    List<Translation> translation = [];
                    for(int index=0; index<_languageList!.length; index++) {
                      translation.add(Translation(
                        locale: _languageList![index].key, key: 'title',
                        value: _titleController[index].text.trim().isNotEmpty ? _titleController[index].text.trim()
                            : _titleController[0].text.trim(),
                      ));
                    }
                    if(widget.coupon == null){
                      couponController.addCoupon(title: jsonEncode(translation), code: code, startDate: startDate, expireDate: expireDate,
                        couponType: couponController.couponTypeIndex == 0 ? 'default' : 'free_delivery', discount: discount,
                        discountType: couponController.discountTypeIndex == 0 ? 'percent' : 'amount', limit: _limitController.text.trim(),
                        maxDiscount: _maxDiscountController.text.trim(), minPurches: _minPurchaseController.text.trim(),
                      );
                    }else{
                      couponController.updateCoupon(couponId: widget.coupon!.id.toString(), title: jsonEncode(translation), code: code, startDate: startDate, expireDate: expireDate,
                        couponType: couponController.couponTypeIndex == 0 ? 'default' : 'free_delivery', discount: discount,
                        discountType: couponController.discountTypeIndex == 0 ? 'percent' : 'amount', limit: _limitController.text.trim(),
                        maxDiscount: _maxDiscountController.text.trim(), minPurches: _minPurchaseController.text.trim(),
                      );
                    }
                  }
                },
              ) : const Center(child: CircularProgressIndicator()),

            ]);
          }
        ),
      ),
    );
  }
}
