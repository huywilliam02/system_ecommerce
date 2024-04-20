import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:citgroupvn_ecommerce_store/controller/addon_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/data/model/body/variation_body.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/attribute_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/config_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/variant_type_model.dart';
import 'package:citgroupvn_ecommerce_store/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_store/util/images.dart';
import 'package:citgroupvn_ecommerce_store/util/styles.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_drop_down.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_time_picker.dart';
import 'package:citgroupvn_ecommerce_store/view/base/my_text_field.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/store/widget/attribute_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/store/widget/food_variation_view.dart';

class AddItemScreen extends StatefulWidget {
  final Item? item;
  final List<Translation> translations;
  const AddItemScreen({Key? key, required this.item, required this.translations}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _maxOrderQuantityController = TextEditingController();
  final FocusNode _priceNode = FocusNode();
  final FocusNode _discountNode = FocusNode();
  TextEditingController _c = TextEditingController();
  late bool _update;
  late Item _item;
  final Module? _module = Get.find<SplashController>().configModel!.moduleConfig!.module;

  @override
  void initState() {
    super.initState();

    _update = widget.item != null;
    Get.find<StoreController>().getAttributeList(widget.item);
    Get.find<StoreController>().setTag('', isClear: true);
    if(_update) {
      _item = Item.fromJson(widget.item!.toJson());
      if(_item.tags != null && _item.tags!.isNotEmpty){

        for (var tag in _item.tags!) {
          Get.find<StoreController>().setTag(tag.tag, isUpdate: false);
        }
      }
      _priceController.text = _item.price.toString();
      _discountController.text = _item.discount.toString();
      _stockController.text = _item.stock.toString();
      _maxOrderQuantityController.text = _item.maxOrderQuantity.toString();
      Get.find<StoreController>().setDiscountTypeIndex(_item.discountType == 'percent' ? 0 : 1, false);
      Get.find<StoreController>().setVeg(_item.veg == 1, false);
      if(Get.find<SplashController>().getStoreModuleConfig().newVariation!) {
        Get.find<StoreController>().setExistingVariation(_item.foodVariations);
      }
    }else {
      _item = Item(images: []);
      Get.find<StoreController>().setTag('', isUpdate: false, isClear: true);
      Get.find<StoreController>().setEmptyVariationList();
      Get.find<StoreController>().pickImage(false, true);
      Get.find<StoreController>().setVeg(false, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.item != null ? 'update_item'.tr : 'add_item'.tr),
      body: SafeArea(
        child: GetBuilder<StoreController>(builder: (storeController) {
          List<String?> unitList = [];
          if(storeController.unitList != null) {
            for(int index=0; index<storeController.unitList!.length; index++) {
              unitList.add(storeController.unitList![index].unit);
            }
          }

          List<String?> categoryList = [];
          if(storeController.categoryList != null) {
            for(int index=0; index<storeController.categoryList!.length; index++) {
              categoryList.add(storeController.categoryList![index].name);
            }
          }

          List<String?> subCategory = [];
          if(storeController.subCategoryList != null) {
            for(int index=0; index<storeController.subCategoryList!.length; index++) {
              subCategory.add(storeController.subCategoryList![index].name);
            }
          }

          if(_module!.stock! && storeController.variantTypeList!.isNotEmpty) {
            _stockController.text = storeController.totalStock.toString();
          }

          return (storeController.attributeList != null && storeController.categoryList != null && (widget.item != null ? storeController.subCategoryList != null : true)) ? Column(children: [

            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              physics: const BouncingScrollPhysics(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                MyTextField(
                  hintText: 'price'.tr,
                  controller: _priceController,
                  focusNode: _priceNode,
                  nextFocus: _discountNode,
                  isAmount: true,
                  amountIcon: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Row(children: [

                  Expanded(child: MyTextField(
                    hintText: 'discount'.tr,
                    controller: _discountController,
                    focusNode: _discountNode,
                    isAmount: true,
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
                        value: storeController.discountTypeIndex == 0 ? 'percent' : 'amount',
                        items: <String>['percent', 'amount'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.tr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          storeController.setDiscountTypeIndex(value == 'percent' ? 0 : 1, true);
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    ),
                  ])),

                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                (_module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!) ? Align(alignment: Alignment.centerLeft, child: Text(
                  'item_type'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                )) : const SizedBox(),
                (_module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!) ? Row(children: [

                  Expanded(child: RadioListTile<String>(
                    title: Text(
                      'non_veg'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                    groupValue: storeController.isVeg ? 'veg' : 'non_veg',
                    value: 'non_veg',
                    contentPadding: EdgeInsets.zero,
                    onChanged: (String? value) => storeController.setVeg(value == 'veg', true),
                    activeColor: Theme.of(context).primaryColor,
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: RadioListTile<String>(
                    title: Text(
                      'veg'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                    groupValue: storeController.isVeg ? 'veg' : 'non_veg',
                    value: 'veg',
                    contentPadding: EdgeInsets.zero,
                    onChanged: (String? value) => storeController.setVeg(value == 'veg', true),
                    activeColor: Theme.of(context).primaryColor,
                    dense: false,
                  )),

                ]) : const SizedBox(),
                SizedBox(height: (_module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                    ? Dimensions.paddingSizeLarge : 0),

                Row(children: [

                  Expanded(child: CustomDropDown(
                    value: storeController.categoryIndex.toString(), title: 'category'.tr,
                    dataList: categoryList, onChanged: (String value) {
                      storeController.setCategoryIndex(int.parse(value), true);
                      if(value != '0') {
                        storeController.getSubCategoryList(storeController.categoryList![int.parse(value)-1].id, null);
                      }
                    },
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CustomDropDown(
                    value: storeController.subCategoryIndex.toString(),
                    title: 'sub_category'.tr,
                    dataList: subCategory, onChanged: (String value) => storeController.setSubCategoryIndex(int.parse(value), true),
                  )),

                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Row(children: [
                    Expanded(
                      flex: 8,
                      child: MyTextField(
                        hintText: 'tag'.tr,
                        controller: _tagController,
                        inputAction: TextInputAction.done,
                        onSubmit: (name){
                          if(name != null && name.isNotEmpty) {
                            storeController.setTag(name);
                            _tagController.text = '';
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: CustomButton(buttonText: 'add'.tr, onPressed: (){
                          if(_tagController.text != '' && _tagController.text.isNotEmpty) {
                            storeController.setTag(_tagController.text.trim());
                            _tagController.text = '';
                          }
                        }),
                      ),
                    )
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  storeController.tagList.isNotEmpty ? SizedBox(
                    height: 40,
                    child: ListView.builder(
                      shrinkWrap: true, scrollDirection: Axis.horizontal,
                        itemCount: storeController.tagList.length,
                        itemBuilder: (context, index){
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                        child: Center(child: Row(children: [
                          Text(storeController.tagList[index]!, style: robotoMedium.copyWith(color: Theme.of(context).cardColor)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          InkWell(onTap: () => storeController.removeTag(index), child: Icon(Icons.clear, size: 18, color: Theme.of(context).cardColor)),
                        ])),
                      );
                    }),
                  ) : const SizedBox(),
                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Get.find<SplashController>().getStoreModuleConfig().newVariation! ? FoodVariationView(
                  storeController: storeController, item: widget.item,
                ) : AttributeView(storeController: storeController, product: widget.item),

                (_module!.stock! || _module!.unit!) ? Row(children: [
                  _module!.stock! ? Expanded(child: MyTextField(
                    hintText: 'total_stock'.tr,
                    controller: _stockController,
                    isNumber: true,
                    isEnabled: storeController.variantTypeList!.isEmpty,
                  )) : const SizedBox(),
                  SizedBox(width: _module!.stock! ? Dimensions.paddingSizeSmall : 0),

                  _module!.unit! ? Expanded(child: CustomDropDown(
                    value: storeController.unitIndex.toString(), title: 'unit'.tr, dataList: unitList,
                    onChanged: (String value) => storeController.setUnitIndex(int.parse(value), true),
                  )) : const SizedBox(),

                ]) : const SizedBox(),
                SizedBox(height: (_module!.stock! || _module!.unit!) ? Dimensions.paddingSizeLarge : 0),

                MyTextField(
                  hintText: 'maximum_order_quantity'.tr,
                  controller: _maxOrderQuantityController,
                  isNumber: true,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                _module!.addOn! ? Text(
                  'addons'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ) : const SizedBox(),
                SizedBox(height: _module!.addOn! ? Dimensions.paddingSizeExtraSmall : 0),
                _module!.addOn! ? GetBuilder<AddonController>(builder: (addonController) {
                  List<int> addons = [];
                  if(addonController.addonList != null) {
                    for(int index=0; index<addonController.addonList!.length; index++) {
                      if(addonController.addonList![index].status == 1 && !storeController.selectedAddons!.contains(index)) {
                        addons.add(index);
                      }
                    }
                  }
                  return Autocomplete<int>(
                    optionsBuilder: (TextEditingValue value) {
                      if(value.text.isEmpty) {
                        return const Iterable<int>.empty();
                      }else {
                        return addons.where((addon) => addonController.addonList![addon].name!.toLowerCase().contains(value.text.toLowerCase()));
                      }
                    },
                    fieldViewBuilder: (context, controller, node, onComplete) {
                      _c = controller;
                      return Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 5))],
                        ),
                        child: TextField(
                          controller: controller,
                          focusNode: node,
                          onEditingComplete: () {
                            onComplete();
                            controller.text = '';
                          },
                          decoration: InputDecoration(
                            hintText: 'addons'.tr,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), borderSide: BorderSide.none),
                          ),
                        ),
                      );
                    },
                    displayStringForOption: (value) => addonController.addonList![value].name!,
                    onSelected: (int value) {
                      _c.text = '';
                      storeController.setSelectedAddonIndex(value, true);
                      //_addons.removeAt(value);
                    },
                  );
                }) : const SizedBox(),
                SizedBox(height: (_module!.addOn! && storeController.selectedAddons!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),
                _module!.addOn! ? SizedBox(
                  height: storeController.selectedAddons!.isNotEmpty ? 40 : 0,
                  child: ListView.builder(
                    itemCount: storeController.selectedAddons!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Row(children: [
                          GetBuilder<AddonController>(builder: (addonController) {
                            return Text(
                              addonController.addonList![storeController.selectedAddons![index]].name!,
                              style: robotoRegular.copyWith(color: Theme.of(context).cardColor),
                            );
                          }),
                          InkWell(
                            onTap: () => storeController.removeAddon(index),
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(Icons.close, size: 15, color: Theme.of(context).cardColor),
                            ),
                          ),
                        ]),
                      );
                    },
                  ),
                ) : const SizedBox(),
                SizedBox(height: _module!.addOn! ? Dimensions.paddingSizeLarge : 0),

                _module!.itemAvailableTime! ? Row(children: [

                  Expanded(child: CustomTimePicker(
                    title: 'available_time_starts'.tr, time: _item.availableTimeStarts,
                    onTimeChanged: (time) => _item.availableTimeStarts = time,
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CustomTimePicker(
                    title: 'available_time_ends'.tr, time: _item.availableTimeEnds,
                    onTimeChanged: (time) => _item.availableTimeEnds = time,
                  )),

                ]) : const SizedBox(),
                SizedBox(height: _module!.itemAvailableTime! ? Dimensions.paddingSizeLarge : 0),

                Row(children: [
                  Text(
                    'thumbnail_image'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    '(${'max_size_2_mb'.tr})',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error),
                  ),
                ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Align(alignment: Alignment.center, child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: storeController.rawLogo != null ? GetPlatform.isWeb ? Image.network(
                      storeController.rawLogo!.path, width: 150, height: 120, fit: BoxFit.cover,
                    ) : Image.file(
                      File(storeController.rawLogo!.path), width: 120, height: 120, fit: BoxFit.cover,
                    ) : FadeInImage.assetNetwork(
                      placeholder: Images.placeholder,
                      image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${_item.image ?? ''}',
                      height: 120, width: 150, fit: BoxFit.cover,
                      imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 120, width: 150, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0, top: 0, left: 0,
                    child: InkWell(
                      onTap: () => storeController.pickImage(true, false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ])),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Row(children: [
                  Text(
                    'item_images'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    '(${'max_size_2_mb'.tr})',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error),
                  ),
                ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: (1/1),
                    mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: storeController.savedImages.length+storeController.rawImages.length+1,
                  itemBuilder: (context, index) {
                    bool savedImage = index < storeController.savedImages.length;
                    XFile? file = (savedImage || index == (storeController.rawImages.length + storeController.savedImages.length))
                        ? null : storeController.rawImages[index-storeController.savedImages.length];
                    if(index == (storeController.rawImages.length + storeController.savedImages.length)) {
                      return InkWell(
                        onTap: () {
                          if((storeController.savedImages.length+storeController.rawImages.length) < 6) {
                            storeController.pickImages();
                          }else {
                            showCustomSnackBar('maximum_image_limit_is_6'.tr);
                          }
                        },
                        child: Container(
                          height: context.width, width: context.width, alignment: Alignment.center, decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                        ),
                          child: Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: savedImage ? CustomImage(
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${storeController.savedImages[index]}',
                            width: context.width, height: context.width, fit: BoxFit.cover,
                          ) : GetPlatform.isWeb ? Image.network(
                            file!.path, width: context.width, height: context.width, fit: BoxFit.cover,
                          ) : Image.file(
                            File(file!.path), width: context.width, height: context.width, fit: BoxFit.cover,
                          ) ,
                        ),
                        Positioned(
                          right: 0, top: 0,
                          child: InkWell(
                            onTap: () {
                              if(savedImage) {
                                storeController.removeSavedImage(index);
                              }else {
                                storeController.removeImage(index - storeController.savedImages.length);
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Icon(Icons.delete_forever, color: Colors.red),
                            ),
                          ),
                        ),
                      ]),
                    );
                  },
                ),

              ]),
            )),

            !storeController.isLoading ? CustomButton(
              buttonText: _update ? 'update'.tr : 'submit'.tr,
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              height: 50,
              onPressed: () {
                String price = _priceController.text.trim();
                String discount = _discountController.text.trim();
                int maxOrderQuantity = _maxOrderQuantityController.text.isNotEmpty ? int.parse(_maxOrderQuantityController.text) : 0;
                bool haveBlankVariant = false;
                bool blankVariantPrice = false;
                bool blankVariantStock = false;

                bool variationNameEmpty = false;
                bool variationMinMaxEmpty = false;
                bool variationOptionNameEmpty = false;
                bool variationOptionPriceEmpty = false;
                bool variationMinLessThenZero = false;
                bool variationMaxSmallThenMin = false;
                bool variationMaxBigThenOptions = false;
                for(AttributeModel attr in storeController.attributeList!) {
                  if(attr.active && attr.variants.isEmpty) {
                    haveBlankVariant = true;
                    break;
                  }
                }
                if(Get.find<SplashController>().getStoreModuleConfig().newVariation!){
                  for(VariationModelBody variationModel in storeController.variationList!){
                    if(variationModel.nameController!.text.isEmpty){
                      variationNameEmpty = true;
                    }else if(!variationModel.isSingle){
                      if(variationModel.minController!.text.isEmpty || variationModel.maxController!.text.isEmpty){
                        variationMinMaxEmpty = true;
                      }else if(int.parse(variationModel.minController!.text) < 1){
                        variationMinLessThenZero = true;
                      }else if(int.parse(variationModel.maxController!.text) < int.parse(variationModel.minController!.text)){
                        variationMaxSmallThenMin = true;
                      }else if(int.parse(variationModel.maxController!.text) > variationModel.options!.length){
                        variationMaxBigThenOptions = true;
                      }
                    }else {
                      for(Option option in variationModel.options!){
                        if(option.optionNameController!.text.isEmpty){
                          variationOptionNameEmpty = true;
                        }else if(option.optionPriceController!.text.isEmpty){
                          variationOptionPriceEmpty = true;
                        }
                      }
                    }
                  }
                } else{
                  for(VariantTypeModel variantType in storeController.variantTypeList!) {
                    if(variantType.priceController.text.isEmpty) {
                      blankVariantPrice = true;
                      break;
                    }
                    if(_module!.stock! && variantType.stockController.text.isEmpty) {
                      blankVariantStock = true;
                      break;
                    }
                  }
                }

                if(price.isEmpty) {
                  showCustomSnackBar('enter_item_price'.tr);
                }else if(discount.isEmpty) {
                  showCustomSnackBar('enter_item_discount'.tr);
                }else if(storeController.categoryIndex == 0) {
                  showCustomSnackBar('select_a_category'.tr);
                }else if(haveBlankVariant) {
                  showCustomSnackBar('add_at_least_one_variant_for_every_attribute'.tr);
                }else if(blankVariantPrice) {
                  showCustomSnackBar('enter_price_for_every_variant'.tr);
                }else if(variationNameEmpty){
                  showCustomSnackBar('enter_name_for_every_variation'.tr);
                }else if(variationMinMaxEmpty){
                  showCustomSnackBar('enter_min_max_for_every_multipart_variation'.tr);
                }else if(variationOptionNameEmpty){
                  showCustomSnackBar('enter_option_name_for_every_variation'.tr);
                }else if(variationOptionPriceEmpty){
                  showCustomSnackBar('enter_option_price_for_every_variation'.tr);
                }else if(variationMinLessThenZero){
                  showCustomSnackBar('minimum_type_cant_be_less_then_1'.tr);
                }else if(variationMaxSmallThenMin){
                  showCustomSnackBar('max_type_cant_be_less_then_minimum_type'.tr);
                }else if(variationMaxBigThenOptions){
                  showCustomSnackBar('max_type_length_should_not_be_more_then_options_length'.tr);
                }else if(_module!.stock! && blankVariantStock) {
                  showCustomSnackBar('enter_stock_for_every_variant'.tr);
                }else if(_module!.stock! && storeController.variantTypeList!.isEmpty && _stockController.text.trim().isEmpty) {
                  showCustomSnackBar('enter_stock'.tr);
                }else if(_module!.unit! && storeController.unitIndex == 0) {
                  showCustomSnackBar('add_an_unit'.tr);
                }else if(maxOrderQuantity < 0) {
                  showCustomSnackBar('maximum_item_order_quantity_can_not_be_negative'.tr);
                }else if(_module!.itemAvailableTime! && _item.availableTimeStarts == null) {
                  showCustomSnackBar('pick_start_time'.tr);
                }else if(_module!.itemAvailableTime! && _item.availableTimeEnds == null) {
                  showCustomSnackBar('pick_end_time'.tr);
                }else if(!_update && storeController.rawLogo == null) {
                  showCustomSnackBar('upload_item_image'.tr);
                }else {
                  _item.veg = storeController.isVeg ? 1 : 0;
                  _item.price = double.parse(price);
                  _item.discount = double.parse(discount);
                  _item.discountType = storeController.discountTypeIndex == 0 ? 'percent' : 'amount';
                  _item.categoryIds = [];
                  _item.maxOrderQuantity = maxOrderQuantity;
                  _item.categoryIds!.add(CategoryIds(id: storeController.categoryList![storeController.categoryIndex-1].id.toString()));
                  if(storeController.subCategoryIndex != 0) {
                    _item.categoryIds!.add(CategoryIds(id: storeController.subCategoryList![storeController.subCategoryIndex-1].id.toString()));
                  }else {
                    if(_item.categoryIds!.length > 1) {
                      _item.categoryIds!.removeAt(1);
                    }
                  }
                  _item.addOns = [];
                  for (var index in storeController.selectedAddons!) {
                    _item.addOns!.add(Get.find<AddonController>().addonList![index]);
                  }
                  if(_module!.unit!) {
                    _item.unitType = storeController.unitList![storeController.unitIndex - 1].id.toString();
                  }
                  if(_module!.stock!) {
                    _item.stock = int.parse(_stockController.text.trim());
                  }
                  _item.translations = [];
                  _item.translations!.addAll(widget.translations);
                  bool hasEmptyValue = false;
                  if(Get.find<SplashController>().getStoreModuleConfig().newVariation!) {
                    _item.foodVariations = [];
                    for(VariationModelBody variation in storeController.variationList!) {
                      if(variation.nameController!.text.trim().isEmpty) {
                        hasEmptyValue = true;
                        break;
                      }
                      List<VariationValue> values = [];
                      for(Option option in variation.options!) {
                        if(option.optionNameController!.text.trim().isEmpty || option.optionPriceController!.text.trim().isEmpty) {
                          hasEmptyValue = true;
                          break;
                        }
                        values.add(VariationValue(
                          level: option.optionNameController!.text.trim(),
                          optionPrice: option.optionPriceController!.text.trim(),
                        ));
                      }
                      if(hasEmptyValue) {
                        break;
                      }
                      _item.foodVariations!.add(FoodVariation(
                        name: variation.nameController!.text.trim(), type: variation.isSingle ? 'single' : 'multi',
                        min: variation.minController!.text.trim(), max: variation.maxController!.text.trim(),
                        required: variation.required ? 'on' : 'off', variationValues: values,
                      ));
                    }
                  }
                  if(hasEmptyValue) {
                    showCustomSnackBar('set_value_for_all_variation'.tr);
                  }else {
                    storeController.addItem(_item, widget.item == null);
                  }
                }
              },
            ) : const Center(child: CircularProgressIndicator()),

          ]) : const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}