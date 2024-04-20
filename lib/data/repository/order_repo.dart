import 'dart:convert';

import 'package:citgroupvn_ecommerce_delivery/data/api/api_client.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/body/record_location_body.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/body/update_status_body.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/ignore_model.dart';
import 'package:citgroupvn_ecommerce_delivery/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:get/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepo extends GetxService {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  OrderRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getAllOrders() {
    return apiClient.getData(AppConstants.allOrdersUri + getUserToken());
  }

  Future<Response> getCompletedOrderList(int offset) async {
    return await apiClient.getData('${AppConstants.allOrdersUri}?token=${getUserToken()}&offset=$offset&limit=10');
  }

  Future<Response> getCurrentOrders() {
    return apiClient.getData(AppConstants.currentOrdersUri + getUserToken());
  }

  Future<Response> getLatestOrders() {
    return apiClient.getData(AppConstants.latestOrdersUri + getUserToken());
  }

  Future<Response> recordLocation(RecordLocationBody recordLocationBody) {
    recordLocationBody.token = getUserToken();
    return apiClient.postData(AppConstants.recordLocationUri, recordLocationBody.toJson());
  }

  Future<Response> updateOrderStatus(UpdateStatusBody updateStatusBody, List<MultipartBody> proofAttachment) {
    updateStatusBody.token = getUserToken();
    // return apiClient.postData(AppConstants.updateOrderStatusUri, updateStatusBody.toJson());
    return apiClient.postMultipartData(AppConstants.updateOrderStatusUri, updateStatusBody.toJson(), proofAttachment);
  }

  Future<Response> updatePaymentStatus(UpdateStatusBody updateStatusBody) {
    updateStatusBody.token = getUserToken();
    return apiClient.postData(AppConstants.updatePaymentStatusUri, updateStatusBody.toJson());
  }

  Future<Response> getOrderDetails(int? orderID) {
    return apiClient.getData('${AppConstants.orderDetailsUri}${getUserToken()}&order_id=$orderID');
  }

  Future<Response> acceptOrder(int? orderID) {
    return apiClient.postData(AppConstants.acceptOrderUri, {"_method": "put", 'token': getUserToken(), 'order_id': orderID});
  }

  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  void setIgnoreList(List<IgnoreModel> ignoreList) {
    List<String> stringList = [];
    for (var ignore in ignoreList) {
      stringList.add(jsonEncode(ignore.toJson()));
    }
    sharedPreferences.setStringList(AppConstants.ignoreList, stringList);
  }

  List<IgnoreModel> getIgnoreList() {
    List<IgnoreModel> ignoreList = [];
    List<String> stringList = sharedPreferences.getStringList(AppConstants.ignoreList) ?? [];
    for (var ignore in stringList) {
      ignoreList.add(IgnoreModel.fromJson(jsonDecode(ignore)));
    }
    return ignoreList;
  }

  Future<Response> getOrderWithId(int? orderId) {
    return apiClient.getData('${AppConstants.currentOrderUri}${getUserToken()}&order_id=$orderId');
  }

  Future<Response> getCancelReasons() async {
    return await apiClient.getData('${AppConstants.orderCancellationUri}?offset=1&limit=30&type=deliveryman');
  }

  Future<Response> sendDeliveredNotification(int? orderID) {
    return apiClient.postData(AppConstants.deliveredOrderNotificationUri, {"_method": "put", 'token': getUserToken(), 'order_id': orderID});
  }

}