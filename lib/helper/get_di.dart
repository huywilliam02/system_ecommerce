
import 'dart:convert';

import 'package:citgroupvn_ecommerce_delivery/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/chat_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/language_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/notification_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/theme_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/data/repository/auth_repo.dart';
import 'package:citgroupvn_ecommerce_delivery/data/repository/chat_repo.dart';
import 'package:citgroupvn_ecommerce_delivery/data/repository/language_repo.dart';
import 'package:citgroupvn_ecommerce_delivery/data/repository/notification_repo.dart';
import 'package:citgroupvn_ecommerce_delivery/data/repository/order_repo.dart';
import 'package:citgroupvn_ecommerce_delivery/data/repository/splash_repo.dart';
import 'package:citgroupvn_ecommerce_delivery/data/api/api_client.dart';
import 'package:citgroupvn_ecommerce_delivery/util/app_constants.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/language_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

Future<Map<String, Map<String, String>>> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()));

  // Repository
  Get.lazyPut(() => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => LanguageRepo());
  Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => OrderRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => NotificationRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => ChatRepo(apiClient: Get.find(), sharedPreferences: Get.find()));

  // Controller
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => LanguageController(sharedPreferences: Get.find()));
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => OrderController(orderRepo: Get.find()));
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()));
  Get.lazyPut(() => ChatController(chatRepo: Get.find()));

  // Retrieving localized data
  Map<String, Map<String, String>> languages = {};
  for(LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues =  await rootBundle.loadString('assets/language/${languageModel.languageCode}.json');
    Map<String, dynamic> mappedJson = jsonDecode(jsonStringValues);
    Map<String, String> json = {};
    mappedJson.forEach((key, value) {
      json[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] = json;
  }
  return languages;
}
