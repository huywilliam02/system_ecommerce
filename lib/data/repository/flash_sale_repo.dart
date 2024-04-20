import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/data/api/api_client.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';

class FlashSaleRepo extends GetxService {
  final ApiClient apiClient;

  FlashSaleRepo({required this.apiClient});

  Future<Response> getFlashSale() async {
    return await apiClient.getData(AppConstants.flashSaleUri);
  }

  Future<Response> getFlashSaleWithId(int id, int offset) async {
    return await apiClient.getData('${AppConstants.flashSaleProductsUri}?flash_sale_id=$id&offset=$offset&limit=10');
  }
}