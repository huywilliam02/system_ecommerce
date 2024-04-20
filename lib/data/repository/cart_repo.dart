import 'dart:convert';

import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/api/api_client.dart';
import 'package:citgroupvn_ecommerce/data/model/body/place_order_body.dart';
import 'package:citgroupvn_ecommerce/data/model/response/cart_model.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepo{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  CartRepo({required this.apiClient, required this.sharedPreferences});

  List<CartModel> getCartList() {
    List<String> carts = [];
    if(sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList) ?? [];
    }
    List<CartModel> cartList = [];
    for (String cart in carts) {
      CartModel cartModel = CartModel.fromJson(jsonDecode(cart));
      if((cartModel.item?.moduleId ?? 0) == getModuleId()) {
        cartList.add(cartModel);
      }
    }
    return cartList;
  }

  Future<void> addToCartList(List<CartModel> cartProductList) async {
    List<String> carts = [];
    if(sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList) ?? [];
    }
    List<String> cartStringList = [];
    for(String cartString in carts) {
      CartModel cartModel = CartModel.fromJson(jsonDecode(cartString));
      if(cartModel.item!.moduleId != getModuleId()) {
        cartStringList.add(cartString);
      }
    }
    for(CartModel cartModel in cartProductList) {
      cartStringList.add(jsonEncode(cartModel.toJson()));
    }
    await sharedPreferences.setStringList(AppConstants.cartList, cartStringList);
  }

  int getModuleId() {
    return Get.find<SplashController>().module?.id ?? Get.find<SplashController>().cacheModule?.id ?? 0;
  }

  Future<Response> addToCartOnline(OnlineCart cart) async {
    return apiClient.postData('${AppConstants.addCartUri}${!Get.find<AuthController>().isLoggedIn() ? '?guest_id=${Get.find<AuthController>().getGuestId()}' : ''}', cart.toJson());
  }

  Future<Response> updateCartOnline(OnlineCart cart) async {
    return apiClient.postData('${AppConstants.updateCartUri}${!Get.find<AuthController>().isLoggedIn() ? '?guest_id=${Get.find<AuthController>().getGuestId()}' : ''}', cart.toJson());
  }

  Future<Response> updateCartQuantityOnline(int cartId, double price, int quantity) async {
    Map<String, dynamic> data = {
      "cart_id": cartId,
      "price": price,
      "quantity": quantity,
    };
    return apiClient.postData('${AppConstants.updateCartUri}${!Get.find<AuthController>().isLoggedIn() ? '?guest_id=${Get.find<AuthController>().getGuestId()}' : ''}', data);
  }

  Future<Response> getCartDataOnline() async {
    Map<String, String>? header ={
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: AppConstants.languages[0].languageCode!,
      AppConstants.moduleId: '${Get.find<SplashController>().getCacheModule()}',
      'Authorization': 'Bearer ${sharedPreferences.getString(AppConstants.token)}'
    };

    return apiClient.getData(
      '${AppConstants.getCartListUri}${!Get.find<AuthController>().isLoggedIn() ? '?guest_id=${Get.find<AuthController>().getGuestId()}' : ''}',
      headers: Get.find<SplashController>().module?.id == null ? header : null,
    );
  }

  Future<Response> removeCartItemOnline(int cartId, String? guestId) async {
    return apiClient.deleteData('${AppConstants.removeItemCartUri}?cart_id=$cartId${guestId != null ? '&guest_id=$guestId' : ''}');
  }

  Future<Response> clearCartOnline() async {
    return apiClient.deleteData('${AppConstants.removeAllCartUri}${!Get.find<AuthController>().isLoggedIn() ? '?guest_id=${Get.find<AuthController>().getGuestId()}' : ''}');
  }

}