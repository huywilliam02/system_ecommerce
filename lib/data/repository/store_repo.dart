import 'dart:convert';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/data/api/api_client.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/profile_model.dart';
import 'package:citgroupvn_ecommerce_store/util/app_constants.dart';
import 'package:get/get.dart';

class StoreRepo {
  final ApiClient apiClient;
  StoreRepo({required this.apiClient});

  Future<Response> getItemList(String offset, String type) async {
    return await apiClient.getData('${AppConstants.itemListUri}?offset=$offset&limit=10&type=$type');
  }

  Future<Response> getPendingItemList(String offset, String type) async {
    return await apiClient.getData('${AppConstants.pendingItemListUri}?status=$type&offset=$offset&limit=20');
  }

  Future<Response> getPendingItemDetails(int itemId) async {
    return await apiClient.getData('${AppConstants.pendingItemDetailsUri}/$itemId');
  }

  Future<Response> getItemDetails(int itemId) async {
    return await apiClient.getData('${AppConstants.itemDetailsUri}/$itemId');
  }

  Future<Response> getAttributeList() async {
    return apiClient.getData(AppConstants.attributeUri);
  }

  Future<Response> getCategoryList() async {
    return await apiClient.getData(AppConstants.categoryUri);
  }

  Future<Response> getSubCategoryList(int? parentID) async {
    return await apiClient.getData('${AppConstants.subCategoryUri}$parentID');
  }

  Future<Response> updateStore(Store store, XFile? logo, XFile? cover, String min, String max, String type, List<Translation> translation) async {
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      '_method': 'put', 'name': store.name!, 'contact_number': store.phone!, 'schedule_order': store.scheduleOrder! ? '1' : '0',
      'address': store.address!, 'minimum_order': store.minimumOrder.toString(), 'delivery': store.delivery! ? '1' : '0',
      'take_away': store.takeAway! ? '1' : '0', 'gst_status': store.gstStatus! ? '1' : '0', 'gst': store.gstCode!,
      'minimum_delivery_charge': store.minimumShippingCharge.toString(), 'per_km_delivery_charge': store.perKmShippingCharge.toString(),
      'veg': store.veg.toString(), 'non_veg': store.nonVeg.toString(),
      'order_place_to_schedule_interval': store.orderPlaceToScheduleInterval.toString(), 'minimum_delivery_time': min,
      'maximum_delivery_time': max, 'delivery_time_type': type, 'prescription_order': store.prescriptionStatus! ? '1' : '0',
      'cutlery': store.cutlery! ? '1' : '0', 'translations': jsonEncode(translation), 'meta_title': store.metaTitle!,
      'meta_description': store.metaDescription!, 'meta_key_word': store.metaKeyWord!, 'free_delivery': store.freeDelivery! ? '1' : '0',
    });
    if(store.maximumShippingCharge != null){
      fields.addAll({'maximum_delivery_charge':  store.maximumShippingCharge.toString()});
    }
    return apiClient.postMultipartData(
      AppConstants.vendorUpdateUri, fields, [MultipartBody('logo', logo), MultipartBody('cover_photo', cover)],
    );
  }

  Future<Response> addItem(Item item, XFile? image, List<XFile> images, List<String> savedImages, Map<String, String> attributes, bool isAdd, String tags) async {
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      'price': item.price.toString(), 'discount': item.discount.toString(), 'veg': item.veg.toString(),
      'discount_type': item.discountType!, 'category_id': item.categoryIds![0].id!,
      'translations': jsonEncode(item.translations), 'tags': tags, 'maximum_cart_quantity': item.maxOrderQuantity.toString(),
    });
    if(Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!) {
      fields.addAll((<String, String> {'current_stock': item.stock.toString()}));
    }
    if(Get.find<SplashController>().configModel!.moduleConfig!.module!.unit!) {
      fields.addAll((<String, String> {'unit': item.unitType!}));
    }
    if(Get.find<SplashController>().configModel!.moduleConfig!.module!.itemAvailableTime!) {
      fields.addAll((<String, String> {'available_time_starts': item.availableTimeStarts!, 'available_time_ends': item.availableTimeEnds!}));
    }
    String addon = '';
    for(int index=0; index<item.addOns!.length; index++) {
      addon = '$addon${index == 0 ? item.addOns![index].id : ',${item.addOns![index].id}'}';
    }
    fields.addAll(<String, String> {'addon_ids': addon});
    if(item.categoryIds!.length > 1) {
      fields.addAll(<String, String> {'sub_category_id': item.categoryIds![1].id!});
    }
    if(!isAdd) {
      fields.addAll(<String, String> {'_method': 'put', 'id': item.itemId != null ? item.itemId.toString() : item.id.toString(), 'images': jsonEncode(savedImages)});
    }
    if(Get.find<SplashController>().getStoreModuleConfig().newVariation! && item.foodVariations!.isNotEmpty) {
      fields.addAll({'options': jsonEncode(item.foodVariations)});
    }
    else if(!Get.find<SplashController>().getStoreModuleConfig().newVariation! && attributes.isNotEmpty) {
      fields.addAll(attributes);
    }
    List<MultipartBody> images0 = [];
    images0.add(MultipartBody('image', image));
    for(int index=0; index<images.length; index++) {
      images0.add(MultipartBody('item_images[]', images[index]));
    }
    return apiClient.postMultipartData(
      isAdd ? AppConstants.addItemUri : AppConstants.updateItemUri, fields,images0,
    );
  }

  Future<Response> deleteItem(int? itemID, bool pendingItem) async {
    return await apiClient.deleteData('${AppConstants.deleteItemUri}?id=$itemID${pendingItem ? '&temp_product=1' : ''}');
  }

  Future<Response> getStoreReviewList(int? storeID) async {
    return await apiClient.getData('${AppConstants.vendorReviewUri}?store_id=$storeID');
  }

  Future<Response> getItemReviewList(int? itemID) async {
    return await apiClient.getData('${AppConstants.itemReviewUri}/$itemID');
  }

  Future<Response> updateItemStatus(int? itemID, int status) async {
    return await apiClient.getData('${AppConstants.updateItemStatusUri}?id=$itemID&status=$status');
  }

  Future<Response> addSchedule(Schedules schedule) async {
    return await apiClient.postData(AppConstants.addSchedule, schedule.toJson());
  }

  Future<Response> deleteSchedule(int? scheduleID) async {
    return await apiClient.deleteData('${AppConstants.deleteSchedule}$scheduleID');
  }

  Future<Response> getUnitList() async {
    return await apiClient.getData(AppConstants.unitListUri);
  }

  Future<Response> updateRecommendedProductStatus(int? productID, int status) async {
    return await apiClient.getData('${AppConstants.updateProductRecommendedUri}?id=$productID&status=$status');
  }

  Future<Response> updateOrganicProductStatus(int? productID, int status) async {
    return await apiClient.getData('${AppConstants.updateProductOrganicUri}?id=$productID&organic=$status');
  }

  Future<Response> addBanner(String title, String url, XFile image) async {
    return await apiClient.postMultipartData(AppConstants.addStoreBannerUri, {'title': title, 'default_link': url}, [MultipartBody('image', image)]);
  }

  Future<Response> getBannerList() async {
    return await apiClient.getData(AppConstants.storeBannerUri);
  }

  Future<Response> deleteBanner(int? bannerID) async {
    return await apiClient.deleteData('${AppConstants.deleteStoreBannerUri}?id=$bannerID');
  }

  Future<Response> updateBanner(int? bannerID, String title, String url, XFile? image) async {
    Map<String, String> fields = {};
    fields.addAll(<String, String>{'_method': 'put', 'id': bannerID.toString(), 'title': title, 'default_link': url});
    return await apiClient.postMultipartData(AppConstants.updateStoreBannerUri, fields, [MultipartBody('image', image)]);
  }

  Future<Response> updateAnnouncement(int status, String announcement) async {
    Map<String, String> fields = {'announcement_status': status.toString(), 'announcement_message': announcement, '_method': 'put'};
    return await apiClient.postData(AppConstants.announcementUri, fields);
  }

}