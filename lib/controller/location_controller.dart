import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/cart_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/controller/wishlist_controller.dart';
import 'package:citgroupvn_ecommerce/data/api/api_checker.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/module_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/place_details_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/prediction_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/response_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/zone_response_model.dart';
import 'package:citgroupvn_ecommerce/data/repository/location_repo.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/view/base/confirmation_dialog.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_loader.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citgroupvn_ecommerce/view/screens/location/pick_map_screen.dart';
import 'package:citgroupvn_ecommerce/view/screens/location/widget/module_dialog.dart';
import 'package:citgroupvn_ecommerce/view/screens/location/widget/permission_dialog.dart';

class LocationController extends GetxController implements GetxService {
  final LocationRepo locationRepo;
  LocationController({required this.locationRepo});

  Position _position = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1);
  Position _pickPosition = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 1,
    headingAccuracy: 1,
  );
  bool _loading = false;
  String? _address = '';
  String? _pickAddress = '';
  final List<Marker> _markers = <Marker>[];
  List<AddressModel>? _addressList;
  late List<AddressModel> _allAddressList;
  int _addressTypeIndex = 0;
  final List<String?> _addressTypeList = ['home', 'office', 'others'];
  bool _isLoading = false;
  bool _inZone = false;
  int _zoneID = 0;
  bool _buttonDisabled = true;
  bool _changeAddress = true;
  GoogleMapController? _mapController;
  List<PredictionModel> _predictionList = [];
  bool _updateAddAddressData = true;
  bool _showLocationSuggestion = true;
  bool _showSearchField = false;

  List<PredictionModel> get predictionList => _predictionList;
  bool get isLoading => _isLoading;
  bool get loading => _loading;
  Position get position => _position;
  Position get pickPosition => _pickPosition;
  String? get address => _address;
  String? get pickAddress => _pickAddress;
  List<Marker> get markers => _markers;
  List<AddressModel>? get addressList => _addressList;
  List<String?> get addressTypeList => _addressTypeList;
  int get addressTypeIndex => _addressTypeIndex;
  bool get inZone => _inZone;
  int get zoneID => _zoneID;
  bool get buttonDisabled => _buttonDisabled;
  bool get showLocationSuggestion => _showLocationSuggestion;
  GoogleMapController? get mapController => _mapController;
  bool? get showSearchField => _showSearchField;

  double getRestaurantDistance(LatLng storeLatLng) {
    double distance = 0;
    distance = Geolocator.distanceBetween(
            storeLatLng.latitude,
            storeLatLng.longitude,
            double.parse(getUserAddress()!.latitude!),
            double.parse(getUserAddress()!.longitude!)) /
        1000;

    return distance;
  }

  void hideShowSearch() {
    _showSearchField = !_showSearchField;
    update();
  }

  void hideSuggestedLocation() {
    _showLocationSuggestion = !_showLocationSuggestion;
  }

  Future<AddressModel> getCurrentLocation(bool fromAddress,
      {GoogleMapController? mapController,
      LatLng? defaultLatLng,
      bool notify = true}) async {
    _loading = true;
    if (notify) {
      update();
    }
    AddressModel addressModel;
    Position myPosition;
    try {
      Position newLocalData = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      myPosition = newLocalData;
    } catch (e) {
      myPosition = Position(
        latitude: defaultLatLng != null
            ? defaultLatLng.latitude
            : double.parse(Get.find<SplashController>()
                    .configModel!
                    .defaultLocation!
                    .lat ??
                '0'),
        longitude: defaultLatLng != null
            ? defaultLatLng.longitude
            : double.parse(Get.find<SplashController>()
                    .configModel!
                    .defaultLocation!
                    .lng ??
                '0'),
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 1,
        headingAccuracy: 1,
      );
    }
    if (fromAddress) {
      _position = myPosition;
    } else {
      _pickPosition = myPosition;
    }

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(myPosition.latitude, myPosition.longitude),
            zoom: 17),
      ));
    }
    String addressFromGeocode = await getAddressFromGeocode(
        LatLng(myPosition.latitude, myPosition.longitude));
    fromAddress
        ? _address = addressFromGeocode
        : _pickAddress = addressFromGeocode;
    ZoneResponseModel responseModel = await getZone(
        myPosition.latitude.toString(), myPosition.longitude.toString(), true);
    _buttonDisabled = !responseModel.isSuccess;

    addressModel = AddressModel(
      latitude: myPosition.latitude.toString(),
      longitude: myPosition.longitude.toString(),
      addressType: 'others',
      zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
      zoneIds: responseModel.zoneIds,
      address: addressFromGeocode,
      zoneData: responseModel.zoneData,
      areaIds: responseModel.areaIds,
    );
    _loading = false;
    update();
    return addressModel;
  }

  Future<void> setStoreAddressToUserAddress(LatLng storeAddress) async {
    Position storePosition = Position(
      latitude: storeAddress.latitude,
      longitude: storeAddress.longitude,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    );
    String addressFromGeocode = await getAddressFromGeocode(
        LatLng(storeAddress.latitude, storeAddress.longitude));
    ZoneResponseModel responseModel = await getZone(
        storePosition.latitude.toString(),
        storePosition.longitude.toString(),
        true);
    _buttonDisabled = !responseModel.isSuccess;
    AddressModel addressModel = AddressModel(
      latitude: storePosition.latitude.toString(),
      longitude: storePosition.longitude.toString(),
      addressType: 'others',
      zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
      zoneIds: responseModel.zoneIds,
      address: addressFromGeocode,
      zoneData: responseModel.zoneData,
      areaIds: responseModel.areaIds,
    );
    await Get.find<LocationController>().saveUserAddress(addressModel);

    await Get.find<SplashController>().getModules();
    List<ModuleModel>? modules = Get.find<SplashController>().moduleList;
    for (ModuleModel m in modules!) {
      if (m.id == Get.find<StoreController>().store!.moduleId) {
        Get.find<SplashController>().setModule(m);
      }
    }
  }

  Future<ZoneResponseModel> getZone(String? lat, String? long, bool markerLoad,
      {bool updateInAddress = false}) async {
    if (markerLoad) {
      _loading = true;
    } else {
      _isLoading = true;
    }
    if (!updateInAddress) {
      update();
    }
    ZoneResponseModel responseModel;
    Response response = await locationRepo.getZone(lat, long);
    if (response.statusCode == 200) {
      _inZone = true;
      _zoneID = int.parse(jsonDecode(response.body['zone_id'])[0].toString());
      List<int> zoneIds = [];
      jsonDecode(response.body['zone_id']).forEach((zoneId) {
        zoneIds.add(int.parse(zoneId.toString()));
      });
      List<ZoneData> zoneData = [];
      response.body['zone_data'].forEach((data) {
        zoneData.add(ZoneData.fromJson(data));
      });
      List<int> areaIds = [];

      ///for taxi booking
      // if(response.body['area_id'] != null){
      //   jsonDecode(response.body['area_id']).forEach((areaId) {
      //     _areaIds.add(int.parse(areaId.toString()));
      //   });
      // }else{
      //   showCustomSnackBar('outside_of_city'.tr);
      // }

      responseModel = ZoneResponseModel(true, '', zoneIds, zoneData, areaIds);
      if (updateInAddress) {
        AddressModel address = getUserAddress()!;
        address.zoneData = zoneData;
        saveUserAddress(address);
      }
    } else {
      _inZone = false;
      responseModel = ZoneResponseModel(false, response.statusText, [], [], []);
    }
    if (markerLoad) {
      _loading = false;
    } else {
      _isLoading = false;
    }
    update();
    return responseModel;
  }

  Future<void> syncZoneData() async {
    ZoneResponseModel response = await getZone(
        getUserAddress()!.latitude, getUserAddress()!.longitude, false,
        updateInAddress: true);
    if (response.zoneIds.isEmpty) {
      await saveUserAddress(AddressModel());
      Get.toNamed(RouteHelper.getAccessLocationRoute(RouteHelper.splash));
    } else {
      AddressModel address = getUserAddress()!;
      address.zoneId = response.zoneIds[0];
      address.zoneIds = [];
      address.zoneIds!.addAll(response.zoneIds);
      address.zoneData = [];
      address.zoneData!.addAll(response.zoneData);
      address.areaIds = [];
      address.areaIds!.addAll(response.areaIds);
      await saveUserAddress(address);
    }
    update();
  }

  void updatePosition(CameraPosition? position, bool fromAddress) async {
    if (_updateAddAddressData) {
      _loading = true;
      update();
      try {
        if (fromAddress) {
          _position = Position(
            latitude: position!.target.latitude,
            longitude: position.target.longitude,
            timestamp: DateTime.now(),
            heading: 1,
            accuracy: 1,
            altitude: 1,
            speedAccuracy: 1,
            speed: 1,
            altitudeAccuracy: 1,
            headingAccuracy: 1,
          );
        } else {
          _pickPosition = Position(
            latitude: position!.target.latitude,
            longitude: position.target.longitude,
            timestamp: DateTime.now(),
            heading: 1,
            accuracy: 1,
            altitude: 1,
            speedAccuracy: 1,
            speed: 1,
            altitudeAccuracy: 1,
            headingAccuracy: 1,
          );
        }
        ZoneResponseModel responseModel = await getZone(
            position.target.latitude.toString(),
            position.target.longitude.toString(),
            true);
        _buttonDisabled = !responseModel.isSuccess;
        if (_changeAddress) {
          String addressFromGeocode = await getAddressFromGeocode(
              LatLng(position.target.latitude, position.target.longitude));
          fromAddress
              ? _address = addressFromGeocode
              : _pickAddress = addressFromGeocode;
        } else {
          _changeAddress = true;
        }
      } catch (_) {}
      _loading = false;
      update();
    } else {
      _updateAddAddressData = true;
    }
  }

  Future<ResponseModel> deleteUserAddressByID(int? id, int index) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.removeAddressByID(id);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      _addressList!.removeAt(index);
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> getAddressList() async {
    Response response = await locationRepo.getAllAddress();
    if (response.statusCode == 200) {
      _addressList = [];
      _allAddressList = [];
      response.body['addresses'].forEach((address) {
        _addressList!.add(AddressModel.fromJson(address));
        _allAddressList.add(AddressModel.fromJson(address));
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void filterAddresses(String queryText) {
    if (_addressList != null) {
      _addressList = [];
      if (queryText.isEmpty) {
        _addressList!.addAll(_allAddressList);
      } else {
        for (var address in _allAddressList) {
          if (address.address!
              .toLowerCase()
              .contains(queryText.toLowerCase())) {
            _addressList!.add(address);
          }
        }
      }
      update();
    }
  }

  Future<ResponseModel> addAddress(AddressModel addressModel, bool fromCheckout,
      bool fromRide, int? storeZoneId) async {
    _isLoading = true;
    update();
    Response response = await locationRepo.addAddress(addressModel);
    _isLoading = false;
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      if (fromRide) {
        getAddressList();
        String? message = response.body["message"];
        responseModel = ResponseModel(true, message);
      } else if (fromCheckout &&
          !response.body['zone_ids'].contains(storeZoneId)) {
        responseModel = ResponseModel(
            false,
            Get.find<SplashController>()
                    .configModel!
                    .moduleConfig!
                    .module!
                    .showRestaurantText!
                ? 'your_selected_location_is_from_different_zone'.tr
                : 'your_selected_location_is_from_different_zone_store'.tr);
      } else {
        getAddressList();
        Get.find<OrderController>().setAddressIndex(0);
        String? message = response.body["message"];
        responseModel = ResponseModel(true, message);
      }
    } else {
      responseModel = ResponseModel(
          false,
          response.statusText == 'Out of coverage!'
              ? 'service_not_available_in_this_area'.tr
              : response.statusText);
    }
    update();
    return responseModel;
  }

  Future<ResponseModel> updateAddress(
      AddressModel addressModel, int? addressId) async {
    _isLoading = true;
    update();
    Response response =
        await locationRepo.updateAddress(addressModel, addressId);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      getAddressList();
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<bool> saveUserAddress(AddressModel address) async {
    String userAddress = jsonEncode(address.toJson());
    return await locationRepo.saveUserAddress(userAddress, address.zoneIds,
        address.areaIds, address.latitude, address.longitude);
  }

  AddressModel? getUserAddress() {
    AddressModel? addressModel;
    try {
      addressModel =
          AddressModel.fromJson(jsonDecode(locationRepo.getUserAddress()!));
    } catch (_) {}
    return addressModel;
  }

  void setAddressTypeIndex(int index, {bool isUpdate = true}) {
    _addressTypeIndex = index;
    if (isUpdate) {
      update();
    }
  }

  void saveAddressAndNavigate(AddressModel? address, bool fromSignUp,
      String? route, bool canRoute, bool isDesktop) {
    if (Get.find<CartController>().cartList.isNotEmpty) {
      Get.dialog(ConfirmationDialog(
        icon: Images.warning,
        title: 'are_you_sure_to_reset'.tr,
        description: 'if_you_change_location'.tr,
        onYesPressed: () {
          Get.back();
          _setZoneData(address!, fromSignUp, route, canRoute, isDesktop);
        },
        onNoPressed: () {
          Get.back();
          Get.back();
        },
      ));
    } else {
      _setZoneData(address!, fromSignUp, route, canRoute, isDesktop);
    }
  }

  void _setZoneData(AddressModel address, bool fromSignUp, String? route,
      bool canRoute, bool isDesktop) {
    Get.find<LocationController>()
        .getZone(address.latitude, address.longitude, false)
        .then((response) async {
      if (response.isSuccess) {
        Get.find<CartController>().clearCartList();
        address.zoneId = response.zoneIds[0];
        address.zoneIds = [];
        address.zoneIds!.addAll(response.zoneIds);
        address.zoneData = [];
        address.zoneData!.addAll(response.zoneData);
        address.areaIds = [];
        address.areaIds!.addAll(response.areaIds);
        autoNavigate(address, fromSignUp, route, canRoute, isDesktop);
      } else {
        Get.back();
        showCustomSnackBar(response.message);
      }
    });
  }

  void autoNavigate(AddressModel? address, bool fromSignUp, String? route,
      bool canRoute, bool isDesktop) async {
    if (isDesktop && Get.find<SplashController>().configModel!.module == null) {
      List<int>? zoneIds = address!.zoneIds;
      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
        AppConstants.zoneId: zoneIds != null ? jsonEncode(zoneIds) : '',
      };

      await Get.find<SplashController>().getModules(headers: header);
      if (Get.isDialogOpen!) {
        Get.back();
      }
      Get.dialog(ModuleDialog(callback: () {
        saveData(address, fromSignUp, route, canRoute, isDesktop);
      }),
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.7));
    } else {
      saveData(address!, fromSignUp, route, canRoute, isDesktop);
    }
  }

  void saveData(AddressModel address, bool fromSignUp, String? route,
      bool canRoute, bool isDesktop) async {
    if (!GetPlatform.isWeb) {
      if (Get.find<LocationController>().getUserAddress() != null) {
        if (Get.find<LocationController>().getUserAddress()!.zoneIds != null) {
          for (int zoneID
              in Get.find<LocationController>().getUserAddress()!.zoneIds!) {
            FirebaseMessaging.instance
                .unsubscribeFromTopic('zone_${zoneID}_customer');
          }
        } else {
          FirebaseMessaging.instance.unsubscribeFromTopic(
              'zone_${Get.find<LocationController>().getUserAddress()!.zoneId}_customer');
        }
      } else {
        FirebaseMessaging.instance
            .subscribeToTopic('zone_${address.zoneId}_customer');
      }
      if (address.zoneIds != null) {
        for (int zoneID in address.zoneIds!) {
          FirebaseMessaging.instance
              .subscribeToTopic('zone_${zoneID}_customer');
        }
      } else {
        FirebaseMessaging.instance
            .subscribeToTopic('zone_${address.zoneId}_customer');
      }
    }
    await Get.find<LocationController>().saveUserAddress(address);
    if (Get.find<AuthController>().isLoggedIn()) {
      if (Get.find<SplashController>().module != null) {
        await Get.find<WishListController>().getWishList();
      }
      Get.find<AuthController>().updateZone();
    }
    HomeScreen.loadData(true);
    Get.find<OrderController>().clearPrevData(address.zoneId);
    if (fromSignUp) {
      Get.offAllNamed(RouteHelper.getInterestRoute());
    } else {
      if (route != null && canRoute) {
        Get.offAllNamed(route);
      } else {
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }
    }
  }

  Future<AddressModel> setLocation(String? placeID, String? address,
      GoogleMapController? mapController) async {
    _loading = true;
    update();

    LatLng latLng = const LatLng(0, 0);
    Response response = await locationRepo.getPlaceDetails(placeID);
    if (response.statusCode == 200) {
      PlaceDetailsModel placeDetails =
          PlaceDetailsModel.fromJson(response.body);
      if (placeDetails.status == 'OK') {
        latLng = LatLng(placeDetails.result!.geometry!.location!.lat!,
            placeDetails.result!.geometry!.location!.lng!);
      }
    }

    _pickPosition = Position(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,    altitudeAccuracy: 1,
    headingAccuracy: 1,
    );

    _pickAddress = address;
    _changeAddress = false;

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 17)));
    }
    _loading = false;
    update();
    return AddressModel(
      latitude: _pickPosition.latitude.toString(),
      longitude: _pickPosition.longitude.toString(),
      addressType: 'others',
      address: _pickAddress,
    );
  }

  void disableButton() {
    _buttonDisabled = true;
    _inZone = true;
    update();
  }

  void setAddAddressData() {
    _position = _pickPosition;
    _address = _pickAddress;
    _updateAddAddressData = false;
    update();
  }

  void setUpdateAddress(AddressModel address) {
    _position = Position(
      latitude: double.parse(address.latitude!),
      longitude: double.parse(address.longitude!),
      timestamp: DateTime.now(),
      altitude: 1,    altitudeAccuracy: 1,
    headingAccuracy: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      floor: 1,
      accuracy: 1,
    );
    _address = address.address;
    _addressTypeIndex = _addressTypeList.indexOf(address.addressType);
  }

  void setPickData() {
    _pickPosition = _position;
    _pickAddress = _address;
  }

  void setMapController(GoogleMapController mapController) {
    _mapController = mapController;
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    Response response = await locationRepo.getAddressFromGeocode(latLng);
    String address = 'Unknown Location Found';
    if (response.statusCode == 200 && response.body['status'] == 'OK') {
      address = response.body['results'][0]['formatted_address'].toString();
    } else {
      showCustomSnackBar(response.body['error_message'] ?? response.bodyString);
    }
    return address;
  }

  Future<List<PredictionModel>> searchLocation(
      BuildContext context, String text) async {
    if (text.isNotEmpty) {
      Response response = await locationRepo.searchLocation(text);
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        _predictionList = [];
        response.body['predictions'].forEach((prediction) =>
            _predictionList.add(PredictionModel.fromJson(prediction)));
      } else {
        showCustomSnackBar(
            response.body['error_message'] ?? response.bodyString);
      }
    }
    return _predictionList;
  }

  void setPlaceMark(String address) {
    _address = address;
  }

  void checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    } else {
      onTap();
    }
  }

  Future<bool> checkLocationActive() async {
    bool isActiveLocation = await Geolocator.isLocationServiceEnabled();

    if (isActiveLocation) {
      Position myPosition;
      try {
        myPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      } catch (e) {
        myPosition = Position(
          latitude: double.parse(
              Get.find<SplashController>().configModel!.defaultLocation!.lat ??
                  '0'),
          longitude: double.parse(
              Get.find<SplashController>().configModel!.defaultLocation!.lng ??
                  '0'),
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          heading: 1,
          speed: 1,    altitudeAccuracy: 1,
    headingAccuracy: 1,
          speedAccuracy: 1,
        );
      }

      double distance = Geolocator.distanceBetween(
            double.parse(getUserAddress()!.latitude!),
            double.parse(getUserAddress()!.longitude!),
            myPosition.latitude,
            myPosition.longitude,
          ) /
          1000;

      if (kDebugMode) {
        print('======== distance is : $distance');
      }
      if (distance > 1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> navigateToLocationScreen(String page,
      {bool offNamed = false, bool offAll = false}) async {
    bool fromSignup = page == RouteHelper.signUp;
    bool fromHome = page == 'home';
    if (!fromHome && Get.find<LocationController>().getUserAddress() != null) {
      Get.dialog(const CustomLoader(), barrierDismissible: false);
      Get.find<LocationController>().autoNavigate(
        Get.find<LocationController>().getUserAddress(),
        fromSignup,
        null,
        false,
        ResponsiveHelper.isDesktop(Get.context),
      );
    } else if (Get.find<AuthController>().isLoggedIn()) {
      Get.dialog(const CustomLoader(), barrierDismissible: false);
      await Get.find<LocationController>().getAddressList();
      Get.back();
      if (Get.find<LocationController>().addressList != null &&
          Get.find<LocationController>().addressList!.isEmpty) {
        if (ResponsiveHelper.isDesktop(Get.context)) {
          showGeneralDialog(
              context: Get.context!,
              pageBuilder: (_, __, ___) {
                return SizedBox(
                  height: 300,
                  width: 300,
                  child: PickMapScreen(
                      fromSignUp: (page == RouteHelper.signUp),
                      canRoute: false,
                      fromAddAddress: false,
                      route: null,
                      googleMapController: mapController),
                );
              });
        } else {
          Get.toNamed(RouteHelper.getPickMapRoute(page, false));
        }
      } else {
        if (offNamed) {
          Get.offNamed(RouteHelper.getAccessLocationRoute(page));
        } else if (offAll) {
          Get.offAllNamed(RouteHelper.getAccessLocationRoute(page));
        } else {
          Get.toNamed(RouteHelper.getAccessLocationRoute(page));
        }
      }
    } else {
      if (ResponsiveHelper.isDesktop(Get.context)) {
        showGeneralDialog(
            context: Get.context!,
            pageBuilder: (_, __, ___) {
              return SizedBox(
                  height: 300,
                  width: 300,
                  child: PickMapScreen(
                      fromSignUp: (page == RouteHelper.signUp),
                      canRoute: false,
                      fromAddAddress: false,
                      route: null,
                      googleMapController: mapController));
            });
      } else {
        Get.toNamed(RouteHelper.getPickMapRoute(page, false));
      }
    }
  }
}
