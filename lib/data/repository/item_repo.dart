import 'package:citgroupvn_ecommerce/data/api/api_client.dart';
import 'package:citgroupvn_ecommerce/data/model/body/review_body.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:get/get.dart';

class ItemRepo extends GetxService {
  final ApiClient apiClient;
  ItemRepo({required this.apiClient});

  Future<Response> getPopularItemList(String type) async {
    return await apiClient.getData('${AppConstants.popularItemUri}?type=$type');
  }

  Future<Response> getReviewedItemList(String type) async {
    return await apiClient.getData('${AppConstants.reviewedItemUri}?type=$type');
  }

  Future<Response> getFeaturedCategoriesItemList() async {
    return await apiClient.getData('${AppConstants.featuredCategoriesItemsUri}?limit=30&offset=1');
  }

  Future<Response> getRecommendedItemList(String type) async {
    return await apiClient.getData('${AppConstants.recommendedItemsUri}$type&limit=30');
  }

  Future<Response> getDiscountedItemList() async {
    return await apiClient.getData('${AppConstants.discountedItemsUri}?offset=1&limit=50');
  }

  Future<Response> submitReview(ReviewBody reviewBody) async {
    return await apiClient.postData(AppConstants.reviewUri, reviewBody.toJson());
  }

  Future<Response> submitDeliveryManReview(ReviewBody reviewBody) async {
    return await apiClient.postData(AppConstants.deliveryManReviewUri, reviewBody.toJson());
  }

  Future<Response> getItemDetails(int? itemID) async {
    return apiClient.getData('${AppConstants.itemDetailsUri}$itemID');
  }

  Future<Response> getBasicMedicine() async {
    return apiClient.getData('${AppConstants.basicMedicineUri}?offset=1&limit=50');
  }

  Future<Response> getCommonConditions() async {
    return apiClient.getData(AppConstants.commonConditionUri);
  }

  Future<Response> getConditionsWiseItem(int id) async {
    return apiClient.getData('${AppConstants.conditionWiseItemUri}$id?limit=15&offset=1');
  }

  
}
