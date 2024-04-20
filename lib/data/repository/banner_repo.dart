import 'package:citgroupvn_ecommerce/data/api/api_client.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';
class BannerRepo {
  final ApiClient apiClient;
  BannerRepo({required this.apiClient});

  Future<Response> getBannerList() async {
    return await apiClient.getData(AppConstants.bannerUri);
  }

  Future<Response> getTaxiBannerList() async {
    return await apiClient.getData(AppConstants.taxiBannerUri);
  }

  Future<Response> getFeaturedBannerList() async {
    return await apiClient.getData('${AppConstants.bannerUri}?featured=1');
  }

  Future<Response> getParcelOtherBannerList() async {
    return await apiClient.getData(AppConstants.parcelOtherBannerUri);
  }

  Future<Response> getPromotionalBanner() async {
    return await apiClient.getData(AppConstants.promotionalBannerUri);
  }

}