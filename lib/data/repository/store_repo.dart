
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/api/api_client.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';

class StoreRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  StoreRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getStoreList(int offset, String filterBy) async {
    return await apiClient.getData('${AppConstants.storeUri}/$filterBy?offset=$offset&limit=12');
  }

  Future<Response> getPopularStoreList(String type) async {
    return await apiClient.getData('${AppConstants.popularStoreUri}?type=$type');
  }

  Future<Response> getLatestStoreList(String type) async {
    return await apiClient.getData('${AppConstants.latestStoreUri}?type=$type');
  }

  Future<Response> getFeaturedStoreList() async {
    return await apiClient.getData('${AppConstants.storeUri}/all?featured=1&offset=1&limit=50');
  }

  Future<Response> getVisitAgainStoreList() async {
    return await apiClient.getData(AppConstants.visitAgainStoreUri);
  }

  Future<Response> getStoreDetails(String storeID, bool fromCart, String slug) async {
    Map<String, String>? header ;
    if(fromCart){
      AddressModel? addressModel = Get.find<LocationController>().getUserAddress();
      header = apiClient.updateHeader(
        sharedPreferences.getString(AppConstants.token), addressModel?.zoneIds, addressModel?.areaIds,
        Get.find<LocalizationController>().locale.languageCode,
        Get.find<SplashController>().module == null ? Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id,
        addressModel?.latitude, addressModel?.longitude, setHeader: false,
      );
    }
    if(slug.isNotEmpty){
      header = apiClient.updateHeader(
        sharedPreferences.getString(AppConstants.token), [], [],
        Get.find<LocalizationController>().locale.languageCode,
        0, '', '', setHeader: false,
      );
    }
    return await apiClient.getData('${AppConstants.storeDetailsUri}${slug.isNotEmpty ? slug : storeID}', headers: header);
  }

  Future<Response> getStoreItemList(int? storeID, int offset, int? categoryID, String type) async {
    return await apiClient.getData(
      '${AppConstants.storeItemUri}?store_id=$storeID&category_id=$categoryID&offset=$offset&limit=13&type=$type',
    );
  }

  Future<Response> getStoreSearchItemList(String searchText, String? storeID, int offset, String type, int? categoryID) async {
    return await apiClient.getData(
      '${AppConstants.searchUri}items/search?store_id=$storeID&name=$searchText&offset=$offset&limit=10&type=$type&category_id=${categoryID ?? ''}',
    );
  }

  Future<Response> getStoreReviewList(String? storeID) async {
    return await apiClient.getData('${AppConstants.storeReviewUri}?store_id=$storeID');
  }
  
  Future<Response> getStoreRecommendedItemList(int? storeId) async {
    return await apiClient.getData('${AppConstants.storeRecommendedItemUri}?store_id=$storeId&offset=1&limit=50');
  }

  Future<Response> getCartStoreSuggestedItemList(int? storeId) async {
    AddressModel? addressModel = Get.find<LocationController>().getUserAddress();
    Map<String, String> header = apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token), addressModel?.zoneIds, addressModel?.areaIds,
      Get.find<LocalizationController>().locale.languageCode,
      Get.find<SplashController>().module == null ? Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id,
      addressModel?.latitude, addressModel?.longitude, setHeader: false,
    );
    return await apiClient.getData('${AppConstants.cartStoreSuggestedItemsUri}?recommended=1&store_id=$storeId&offset=1&limit=50', headers: header);
  }

  Future<Response> getStoreBannerList(int? storeId) async {
    return await apiClient.getData('${AppConstants.storeBannersUri}$storeId');
  }

  Future<Response> getRecommendedStoreList() async {
    return await apiClient.getData(AppConstants.recommendedStoreUri);
  }

}