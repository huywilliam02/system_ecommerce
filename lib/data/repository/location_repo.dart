import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/api/api_client.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  LocationRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getAllAddress() async {
    return await apiClient.getData(AppConstants.addressListUri);
  }

  Future<Response> getZone(String? lat, String? lng) async {
    return await apiClient.getData('${AppConstants.zoneUri}?lat=$lat&lng=$lng');
  }

  Future<Response> removeAddressByID(int? id) async {
    return await apiClient.postData('${AppConstants.removeAddressUri}$id', {"_method": "delete"});
  }

  Future<Response> addAddress(AddressModel addressModel) async {
    return await apiClient.postData(AppConstants.addAddressUri, addressModel.toJson());
  }

  Future<Response> updateAddress(AddressModel addressModel, int? addressId) async {
    return await apiClient.putData('${AppConstants.updateAddressUri}$addressId', addressModel.toJson());
  }

  Future<bool> saveUserAddress(String address, List<int>? zoneIDs, List<int>? areaIDs, String? latitude, String? longitude) async {
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token), zoneIDs, areaIDs,
      sharedPreferences.getString(AppConstants.languageCode),
      Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : null,
      latitude, longitude
    );
    return await sharedPreferences.setString(AppConstants.userAddress, address);
  }

  Future<Response> getAddressFromGeocode(LatLng latLng) async {
    return await apiClient.getData('${AppConstants.geocodeUri}?lat=${latLng.latitude}&lng=${latLng.longitude}');
  }

  String? getUserAddress() {
    return sharedPreferences.getString(AppConstants.userAddress);
  }

  Future<Response> searchLocation(String text) async {
    return await apiClient.getData('${AppConstants.searchLocationUri}?search_text=$text');
  }

  Future<Response> getPlaceDetails(String? placeID) async {
    return await apiClient.getData('${AppConstants.placeDetailsUri}?placeid=$placeID');
  }


  bool getSuggestedLocationStatus() {
    return sharedPreferences.getBool(AppConstants.suggestedLocation)!;
  }

  Future<void> saveSuggestedLocationStatus(bool data) async {
    try {
      await sharedPreferences.setBool(AppConstants.suggestedLocation, data);

    } catch (e) {
      rethrow;
    }
  }

}
