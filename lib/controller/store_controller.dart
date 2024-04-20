import 'dart:convert';

import 'package:citgroupvn_ecommerce_store/controller/addon_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/data/api/api_checker.dart';
import 'package:citgroupvn_ecommerce_store/data/model/body/variation_body.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/attr.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/category_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/attribute_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/pending_item_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/profile_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/review_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/store_banner_list_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/unit_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/variant_type_model.dart';
import 'package:citgroupvn_ecommerce_store/data/repository/store_repo.dart';
import 'package:citgroupvn_ecommerce_store/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class StoreController extends GetxController implements GetxService {
  final StoreRepo storeRepo;
  StoreController({required this.storeRepo});

  List<Item>? _itemList;
  List<ReviewModel>? _storeReviewList;
  List<ReviewModel>? _itemReviewList;
  bool _isLoading = false;
  int? _pageSize;
  List<String> _offsetList = [];
  int _offset = 1;
  List<AttributeModel>? _attributeList;
  int _discountTypeIndex = 0;
  List<CategoryModel>? _categoryList;
  List<CategoryModel>? _subCategoryList;
  XFile? _rawLogo;
  XFile? _rawCover;
  List<int>? _selectedAddons;
  List<VariantTypeModel>? _variantTypeList;
  bool _isAvailable = true;
  List<Schedules>? _scheduleList;
  bool _scheduleLoading = false;
  bool? _isGstEnabled;
  int _tabIndex = 0;
  bool _isVeg = false;
  bool? _isStoreVeg = true;
  bool? _isStoreNonVeg = true;
  String _type = 'all';
  static final List<String> _itemTypeList = ['all', 'veg', 'non_veg'];
  List<UnitModel>? _unitList;
  int _totalStock = 0;
  List<XFile> _rawImages = [];
  List<String> _savedImages = [];
  int _imageIndex = 0;
  int _categoryIndex = 0;
  int _subCategoryIndex = 0;
  int _unitIndex = 0;
  final List<String> _durations = ['min', 'hours', 'days'];
  int _durationIndex = 0;
  List<VariationModelBody>? _variationList;
  List<String?> _tagList = [];
  bool _isRecommended = false;
  bool _isOrganic = false;
  Item? _item;
  List<Items>? _pendingItem;
  List<StoreBannerListModel>? _storeBannerList;
  final List<String> _statusList = ['all', 'pending', 'rejected'];
  int _announcementStatus = 0;
  int _languageSelectedIndex = 0;

  List<Item>? get itemList => _itemList;
  List<ReviewModel>? get storeReviewList => _storeReviewList;
  List<ReviewModel>? get itemReviewList => _itemReviewList;
  bool get isLoading => _isLoading;
  int? get pageSize => _pageSize;
  int get offset => _offset;
  List<AttributeModel>? get attributeList => _attributeList;
  int get discountTypeIndex => _discountTypeIndex;
  List<CategoryModel>? get categoryList => _categoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;
  XFile? get rawLogo => _rawLogo;
  XFile? get rawCover => _rawCover;
  List<int>? get selectedAddons => _selectedAddons;
  List<VariantTypeModel>? get variantTypeList => _variantTypeList;
  bool get isAvailable => _isAvailable;
  List<Schedules>? get scheduleList => _scheduleList;
  bool get scheduleLoading => _scheduleLoading;
  bool? get isGstEnabled => _isGstEnabled;
  int get tabIndex => _tabIndex;
  bool get isVeg => _isVeg;
  bool? get isStoreVeg => _isStoreVeg;
  bool? get isStoreNonVeg => _isStoreNonVeg;
  String get type => _type;
  List<String> get itemTypeList => _itemTypeList;
  List<UnitModel>? get unitList => _unitList;
  int get totalStock => _totalStock;
  List<XFile> get rawImages => _rawImages;
  List<String> get savedImages => _savedImages;
  int get imageIndex => _imageIndex;
  int get categoryIndex => _categoryIndex;
  int get subCategoryIndex => _subCategoryIndex;
  int get unitIndex => _unitIndex;
  List<String> get durations => _durations;
  int get durationIndex => _durationIndex;
  List<VariationModelBody>? get variationList => _variationList;
  List<String?> get tagList => _tagList;
  bool get isRecommended => _isRecommended;
  bool get isOrganic => _isOrganic;
  Item? get item => _item;
  List<Items>? get pendingItem => _pendingItem;
  List<StoreBannerListModel>? get storeBannerList => _storeBannerList;
  List<String> get statusList => _statusList;
  int get announcementStatus => _announcementStatus;
  int get languageSelectedIndex => _languageSelectedIndex;

  void setLanguageSelect(int i) {
    _languageSelectedIndex = i;
    update();
  }

  void setRecommended(bool isRecommended) {
    _isRecommended = isRecommended;
  }

  void setOrganic(bool isOrganic) {
    _isOrganic = isOrganic;
  }

  void toggleRecommendedProduct(int? productID) async {
    Response response = await storeRepo.updateRecommendedProductStatus(productID, _isRecommended ? 0 : 1);
    if(response.statusCode == 200) {
      getItemList('1', 'all');
      _isRecommended = !_isRecommended;
      showCustomSnackBar('food_status_updated_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void toggleOrganicProduct(int? productID) async {
    Response response = await storeRepo.updateOrganicProductStatus(productID, _isOrganic ? 0 : 1);
    if(response.statusCode == 200) {
      getItemList('1', 'all');
      _isOrganic = !_isOrganic;
      showCustomSnackBar('food_status_updated_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setTag(String? name, {bool isUpdate = true, bool isClear = false}){
    if(isClear){
      _tagList = [];
    }else{
      _tagList.add(name);
      if(isUpdate) {
        update();
      }
    }
  }

  void initializeTags(String name){
    _tagList.add(name);
    update();
  }

  void removeTag(int index){
    _tagList.removeAt(index);
    update();
  }

  Future<void> getItemList(String offset, String type) async {
    if(offset == '1') {
      _offsetList = [];
      _offset = 1;
      _type = type;
      _itemList = null;
      update();
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      Response response = await storeRepo.getItemList(offset, type);
      if (response.statusCode == 200) {
        if (offset == '1') {
          _itemList = [];
        }
        _itemList!.addAll(ItemModel.fromJson(response.body).items!);
        _pageSize = ItemModel.fromJson(response.body).totalSize;
        _isLoading = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  Future<Item?> getItemDetails(int itemId) async {
    _isLoading = true;
    update();
    Response response = await storeRepo.getItemDetails(itemId);
    if (response.statusCode == 200) {
      _item = Item.fromJson(response.body);
      _isLoading = false;
      update();
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return _item;
  }

  Future<void> getPendingItemList(String offset, String type, {bool canNotify = true}) async {
    if(offset == '1') {
      _offsetList = [];
      _offset = 1;
      _type = type;
      _pendingItem = null;
      if(canNotify) {
        update();
      }
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      Response response = await storeRepo.getPendingItemList(offset, type);
      if (response.statusCode == 200) {
        if (offset == '1') {
          _pendingItem = [];
        }
        _pendingItem!.addAll(PendingItemModel.fromJson(response.body).items!);
        _pageSize = PendingItemModel.fromJson(response.body).totalSize;
        _isLoading = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }


  Future<bool> getPendingItemDetails(int itemId, {bool canUpdate = true}) async {
    _item = null;
    _languageSelectedIndex = 0;
    bool success = false;
    _isLoading = true;
    if(canUpdate == true) {
      update();
    }
    Response response = await storeRepo.getPendingItemDetails(itemId);
    if (response.statusCode == 200) {
      _item = Item.fromJson(response.body);
      success = true;
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
    return success;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  void getAttributeList(Item? item) async {
    _attributeList = null;
    _discountTypeIndex = 0;
    _rawLogo = null;
    _selectedAddons = [];
    _variantTypeList = [];
    _totalStock = 0;
    _rawImages = [];
    _savedImages = [];
    if(item != null) {
      _savedImages.addAll(item.images!);
    }
    Response response = await storeRepo.getAttributeList();
    if(response.statusCode == 200) {
      _attributeList = [];
      response.body.forEach((attribute) {
        if(item != null) {
          bool active = item.attributes!.contains(Attr.fromJson(attribute).id);
          List<String> options = [];
          if(active) {
            options.addAll(item.choiceOptions![item.attributes!.indexOf(Attr.fromJson(attribute).id)].options!);
          }
          _attributeList!.add(AttributeModel(
            attribute: Attr.fromJson(attribute),
            active: item.attributes!.contains(Attr.fromJson(attribute).id),
            controller: TextEditingController(), variants: options,
          ));
        }else {
          _attributeList!.add(AttributeModel(attribute: Attr.fromJson(attribute), active: false,
            controller: TextEditingController(), variants: [],
          ));
        }
      });
    }else {
      ApiChecker.checkApi(response);
    }
    if(Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn!) {
      List<int?> addonsIds = await Get.find<AddonController>().getAddonList();
      if(item != null && item.addOns != null) {
        for(int index=0; index<item.addOns!.length; index++) {
          setSelectedAddonIndex(addonsIds.indexOf(item.addOns![index].id), false);
        }
      }
    }
    if(Get.find<SplashController>().configModel!.moduleConfig!.module!.unit!) {
      await getUnitList(item);
    }
    generateVariantTypes(item);
    await getCategoryList(item);
  }

  void setDiscountTypeIndex(int index, bool notify) {
    _discountTypeIndex = index;
    if(notify) {
      update();
    }
  }

  void toggleAttribute(int index, Item? product) {
    _attributeList![index].active = !_attributeList![index].active;
    generateVariantTypes(product);
    update();
  }

  void addVariant(int index, String variant, Item? product) {
    _attributeList![index].variants.add(variant);
    generateVariantTypes(product);
    update();
  }

  void removeVariant(int mainIndex, int index, Item? product) {
    _attributeList![mainIndex].variants.removeAt(index);
    generateVariantTypes(product);
    update();
  }

  Future<void> getCategoryList(Item? item) async {
    _categoryList = null;
    _categoryIndex = 0;
    Response response = await storeRepo.getCategoryList();
    if (response.statusCode == 200) {
      _categoryList = [];
      for(int index=0; index<response.body.length; index++) {
        _categoryList!.add(CategoryModel.fromJson(response.body[index]));
        if(item != null) {
          if(CategoryModel.fromJson(response.body[index]).id.toString() == item.categoryIds![0].id) {
            _categoryIndex = index + 1;
          }
        }
      }
      if(item != null) {
        await getSubCategoryList(int.parse(item.categoryIds![0].id!), item);
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getSubCategoryList(int? categoryID, Item? item) async {
    _subCategoryList = null;
    if(categoryID != 0) {
      _subCategoryIndex = 0;
      Response response = await storeRepo.getSubCategoryList(categoryID);
      if (response.statusCode == 200) {
        _subCategoryList = [];
        for(int index=0; index<response.body.length; index++) {
          _subCategoryList!.add(CategoryModel.fromJson(response.body[index]));
          if(item != null && item.categoryIds!.length > 1) {
            if(CategoryModel.fromJson(response.body[index]).id.toString() == item.categoryIds![1].id) {
              _subCategoryIndex = index + 1;
            }
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    }
    update();
  }

  Future<void> updateStore(Store store, String min, String max, String type, List<Translation> translation) async {
    _isLoading = true;
    update();
    Response response = await storeRepo.updateStore(store, _rawLogo, _rawCover, min, max, type, translation);
    if(response.statusCode == 200) {
      await Get.find<AuthController>().getProfile();
      Get.find<StoreController>().getItemList('1', 'all');
      Get.find<StoreController>().getStoreReviewList(Get.find<AuthController>().profileModel!.stores![0].id);
      showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
          ? 'restaurant_settings_updated_successfully'.tr : 'store_settings_updated_successfully'.tr, isError: false);
      Get.offAllNamed(RouteHelper.getMainRoute('cart'));
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void pickImage(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _rawLogo = null;
      _rawCover = null;
    }else {
      if (isLogo) {
        XFile? pickedLogo = await ImagePicker().pickImage(source: ImageSource.gallery);
        if(pickedLogo != null) {
          _rawLogo = pickedLogo;
        }
      } else {
        XFile? pickedCover = await ImagePicker().pickImage(source: ImageSource.gallery);
        if(pickedCover != null) {
          _rawCover = pickedCover;
        }
      }
      update();
    }
  }

  void setSelectedAddonIndex(int index, bool notify) {
    if(!_selectedAddons!.contains(index)) {
      _selectedAddons!.add(index);
      if(notify) {
        update();
      }
    }
  }

  void removeAddon(int index) {
    _selectedAddons!.removeAt(index);
    update();
  }

  Future<void> addItem(Item item, bool isAdd) async {
    _isLoading = true;
    update();
    Map<String, String> fields = {};
    if(!Get.find<SplashController>().getStoreModuleConfig().newVariation! && _variantTypeList!.isNotEmpty) {
      List<int?> idList = [];
      List<String?> nameList = [];
      for (var attributeModel in _attributeList!) {
        if(attributeModel.active) {
          idList.add(attributeModel.attribute.id);
          nameList.add(attributeModel.attribute.name);
          String variantString = '';
          for (var variant in attributeModel.variants) {
            variantString = variantString + (variantString.isEmpty ? '' : ',') + variant.replaceAll(' ', '');
          }
          fields.addAll(<String, String>{'choice_options_${attributeModel.attribute.id}': jsonEncode([variantString])});
        }
      }
      fields.addAll(<String, String> {
        'attribute_id': jsonEncode(idList), 'choice_no': jsonEncode(idList), 'choice': jsonEncode(nameList)
      });
      for(int index=0; index<_variantTypeList!.length; index++) {
        fields.addAll(<String, String> {'price_${_variantTypeList![index].variantType.replaceAll(' ', '_')}': _variantTypeList![index].priceController.text.trim(),
          'stock_${_variantTypeList![index].variantType.replaceAll(' ', '_')}': _variantTypeList![index].stockController.text.trim().isEmpty ? '0'
              : _variantTypeList![index].stockController.text.trim()});
      }
    }
    String tags = '';
    for (var element in _tagList) {
      tags = tags + (tags.isEmpty ? '' : ',') + element!.replaceAll(' ', '');
    }

    Response response = await storeRepo.addItem(item, _rawLogo, _rawImages, _savedImages, fields, isAdd, tags);
    if(response.statusCode == 200) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
      showCustomSnackBar(isAdd ? 'product_added_successfully'.tr : 'product_updated_successfully'.tr, isError: false);
      _tagList.clear();
      getItemList('1', 'all');
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> deleteItem(int? itemID, {bool pendingItem = false}) async {
    _isLoading = true;
    update();
    Response response = await storeRepo.deleteItem(itemID, pendingItem);
    if(response.statusCode == 200) {
      Get.back();
      showCustomSnackBar('product_deleted_successfully'.tr, isError: false);
      if(pendingItem) {
        getPendingItemList(offset.toString(), type);
      }else {
        getItemList('1', 'all');
      }
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void generateVariantTypes(Item? item) {
    List<List<String>> mainList = [];
    int length = 1;
    bool hasData = false;
    List<int> indexList = [];
    _variantTypeList = [];
    _totalStock = 0;
    for (var attribute in _attributeList!) {
      if(attribute.active) {
        hasData = true;
        mainList.add(attribute.variants);
        length = length * attribute.variants.length;
        indexList.add(0);
      }
    }
    if(!hasData) {
      length = 0;
    }
    for(int i=0; i<length; i++) {
      String value = '';
      for(int j=0; j<mainList.length; j++) {
        value = value + (value.isEmpty ? '' : '-') + mainList[j][indexList[j]].trim();
      }
      if(item != null && item.variations != null) {
        double? price = 0;
        int? stock = 0;
        for(Variation variation in item.variations!) {
          if(variation.type == value) {
            price = variation.price;
            stock = variation.stock;
            break;
          }
        }
        _totalStock = _totalStock + stock!;
        _variantTypeList!.add(VariantTypeModel(
          variantType: value, priceController: TextEditingController(text: price! > 0 ? price.toString() : ''), priceNode: FocusNode(),
          stockController: TextEditingController(text: stock > 0 ? stock.toString() : ''), stockNode: FocusNode(),
        ));
      }else {
        _variantTypeList!.add(VariantTypeModel(
          variantType: value, priceController: TextEditingController(), priceNode: FocusNode(),
          stockController: TextEditingController(), stockNode: FocusNode(),
        ));
      }

      for(int j=0; j<mainList.length; j++) {
        if(indexList[indexList.length-(1+j)] < mainList[mainList.length-(1+j)].length-1) {
          indexList[indexList.length-(1+j)] = indexList[indexList.length-(1+j)] + 1;
          break;
        }else {
          indexList[indexList.length-(1+j)] = 0;
        }
      }
    }
  }

  bool hasAttribute() {
    bool hasData = false;
    for(AttributeModel attribute in _attributeList!) {
      if(attribute.active) {
        hasData = true;
        break;
      }
    }
    return hasData;
  }

  Future<void> getStoreReviewList(int? storeID) async {
    _tabIndex = 0;
    Response response = await storeRepo.getStoreReviewList(storeID);
    if(response.statusCode == 200) {
      _storeReviewList = [];
      response.body.forEach((review) => _storeReviewList!.add(ReviewModel.fromJson(review)));
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getItemReviewList(int? itemID) async {
    _itemReviewList = null;
    Response response = await storeRepo.getItemReviewList(itemID);
    if(response.statusCode == 200) {
      _itemReviewList = [];
      response.body['reviews'].forEach((review) {
        _itemReviewList!.add(ReviewModel.fromJson(review));
      });
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setAvailability(bool isAvailable) {
    _isAvailable = isAvailable;
  }

  void toggleAvailable(int? productID) async {
    Response response = await storeRepo.updateItemStatus(productID, _isAvailable ? 0 : 1);
    if(response.statusCode == 200) {
      getItemList('1', 'all');
      _isAvailable = !_isAvailable;
      showCustomSnackBar('item_status_updated_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void initStoreData(Store store) {
    _rawLogo = null;
    _rawCover = null;
    _isGstEnabled = store.gstStatus;
    _scheduleList = [];
    _scheduleList!.addAll(store.schedules!);
    _isStoreVeg = store.veg == 1;
    _isStoreNonVeg = store.nonVeg == 1;

  }

  void toggleGst() {
    _isGstEnabled = !_isGstEnabled!;
    update();
  }

  Future<void> addSchedule(Schedules schedule) async {
    schedule.openingTime = '${schedule.openingTime!}:00';
    schedule.closingTime = '${schedule.closingTime!}:00';
    _scheduleLoading = true;
    update();
    Response response = await storeRepo.addSchedule(schedule);
    if(response.statusCode == 200) {
      schedule.id = int.parse(response.body['id'].toString());
      _scheduleList!.add(schedule);
      Get.back();
      showCustomSnackBar('schedule_added_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _scheduleLoading = false;
    update();
  }

  Future<void> deleteSchedule(int? scheduleID) async {
    _scheduleLoading = true;
    update();
    Response response = await storeRepo.deleteSchedule(scheduleID);
    if(response.statusCode == 200) {
      _scheduleList!.removeWhere((schedule) => schedule.id == scheduleID);
      Get.back();
      showCustomSnackBar('schedule_removed_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _scheduleLoading = false;
    update();
  }

  void setTabIndex(int index) {
    bool notify = true;
    if(_tabIndex == index) {
      notify = false;
    }
    _tabIndex = index;
    if(notify) {
      update();
    }
  }

  void setVeg(bool isVeg, bool notify) {
    _isVeg = isVeg;
    if(notify) {
      update();
    }
  }

  void setStoreVeg(bool? isVeg, bool notify) {
    _isStoreVeg = isVeg;
    if(notify) {
      update();
    }
  }

  void setStoreNonVeg(bool? isNonVeg, bool notify) {
    _isStoreNonVeg = isNonVeg;
    if(notify) {
      update();
    }
  }

  Future<void> getUnitList(Item? item) async {
    _unitIndex = 0;
    Response response = await storeRepo.getUnitList();
    if(response.statusCode == 200) {
      _unitList = [];
      for(int index=0; index<response.body.length; index++) {
        _unitList!.add(UnitModel.fromJson(response.body[index]));
        if(item != null) {
          if (UnitModel.fromJson(response.body[index]).unit == item.unitType) {
            _unitIndex = index + 1;
          }
        }
      }
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setTotalStock() {
    _totalStock = 0;
    for (var variant in _variantTypeList!) {
      _totalStock = variant.stockController.text.trim().isNotEmpty
        ? _totalStock + int.parse(variant.stockController.text.trim()) : _totalStock;
    }
    update();
  }

  void pickImages() async {
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(xFile != null) {
      _rawImages.add(xFile);
    }
    update();
  }

  void removeImage(int index) {
    _rawImages.removeAt(index);
    update();
  }

  void removeSavedImage(int index) {
    _savedImages.removeAt(index);
    update();
  }

  void setImageIndex(int index, bool notify) {
    _imageIndex = index;
    if(notify) {
      update();
    }
  }

  void setCategoryIndex(int index, bool notify) {
    _categoryIndex = index;
    if(notify) {
      update();
    }
  }

  void setSubCategoryIndex(int index, bool notify) {
    _subCategoryIndex = index;
    if(notify) {
      update();
    }
  }

  void setUnitIndex(int index, bool notify) {
    _unitIndex = index;
    if(notify) {
      update();
    }
  }

  void setDurationType(int index, bool notify) {
    _durationIndex = index;
    if(notify) {
      update();
    }
  }

  void setEmptyVariationList(){
    _variationList = [];
  }

  void setExistingVariation(List<FoodVariation>? variationList) {
    _variationList = [];
    // print('-------${variationList.length}');
    if(variationList != null && variationList.isNotEmpty) {
      for (var variation in variationList) {
        List<Option> options = [];

        for (var option in variation.variationValues!) {
          options.add(Option(
              optionNameController: TextEditingController(text: option.level),
              optionPriceController: TextEditingController(text: option.optionPrice)),
          );
        }

        _variationList!.add(VariationModelBody(
            nameController: TextEditingController(text: variation.name),
            isSingle: variation.type == 'single' ? true : false,
            minController: TextEditingController(text: variation.min),
            maxController: TextEditingController(text: variation.max),
            required: variation.required == 'on' ? true : false,
            options: options),
        );
      }
    }
  }

  void changeSelectVariationType(int index) {
    _variationList![index].isSingle = !_variationList![index].isSingle;
    update();
  }

  void setVariationRequired(int index) {
    _variationList![index].required = !_variationList![index].required;
    update();
  }

  void addVariation() {
    _variationList!.add(VariationModelBody(
      nameController: TextEditingController(), required: false, isSingle: true, maxController: TextEditingController(), minController: TextEditingController(),
      options: [Option(optionNameController: TextEditingController(), optionPriceController: TextEditingController())],
    ));
    update();
  }

  void removeVariation(int index) {
    _variationList!.removeAt(index);
    update();
  }

  void addOptionVariation(int index) {
    _variationList![index].options!.add(Option(optionNameController: TextEditingController(), optionPriceController: TextEditingController()));
    update();
  }

  void removeOptionVariation(int vIndex, int oIndex) {
    _variationList![vIndex].options!.removeAt(oIndex);
    update();
  }

  Future<void> addBanner(String title, String url, XFile image) async {
    _isLoading = true;
    update();
    Response response = await storeRepo.addBanner(title, url, image);
    if(response.statusCode == 200) {
      getBannerList();
      Get.back();
      showCustomSnackBar('banner_added_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  /// This method is used to get the list of banners
  Future<void> getBannerList() async {
    _isLoading = true;
    update();
    Response response = await storeRepo.getBannerList();
    if(response.statusCode == 200) {
      _storeBannerList = [];
      response.body.forEach((item) => _storeBannerList!.add(StoreBannerListModel.fromJson(item)));
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  /// This method is used to delete the banner
  Future<void> deleteBanner(int? bannerID) async {
    _isLoading = true;
    update();
    Response response = await storeRepo.deleteBanner(bannerID);
    if(response.statusCode == 200) {
      getBannerList();
      Get.back();
      showCustomSnackBar('banner_deleted_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  /// This method is used to update the banner
  Future<void> updateBanner(int? bannerID, String title, String url, XFile? image) async {
    _isLoading = true;
    update();
    Response response = await storeRepo.updateBanner(bannerID, title, url, image);
    if(response.statusCode == 200) {
      getBannerList();
      Get.back();
      showCustomSnackBar('banner_updated_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateAnnouncement(int status, String announcement) async{
    _isLoading = true;
    update();
    Response response = await storeRepo.updateAnnouncement(status, announcement);
    if(response.statusCode == 200){
      Get.back();
      showCustomSnackBar('announcement_updated_successfully'.tr, isError: false);
      Get.find<AuthController>().getProfile();
    }else{
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void setAnnouncementStatus(int index){
    _announcementStatus = index;
    update();
  }

}