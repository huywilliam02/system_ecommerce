import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/body/notification_body.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/conversation_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/view/screens/order/widget/track_details_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/order/widget/tracking_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen({Key? key, required this.orderID, this.contactNumber}) : super(key: key);

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  // List<MarkerData> _customMarkers = [];
  Timer? _timer;

  void _loadData() async {
    await Get.find<OrderController>().trackOrder(widget.orderID, null, true, contactNumber: widget.contactNumber);
    await Get.find<LocationController>().getCurrentLocation(true, notify: false, defaultLatLng: LatLng(
      double.parse(Get.find<LocationController>().getUserAddress()!.latitude!),
      double.parse(Get.find<LocationController>().getUserAddress()!.longitude!),
    ));
  }

  void _startApiCall(){
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);
    });
  }

  @override
  void initState() {
    super.initState();

    _loadData();
    _startApiCall();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _timer?.cancel();
  }

  // Widget _customMarker(String path) {
  //   return Stack(
  //     children: [
  //       Image.asset(Images.locationMarker, height: 40, width: 40),
  //       Positioned(top: 3, left: 0, right: 0, child: Center(
  //         child: ClipOval(child: CustomImage(image: path, placeholder: Images.userMarker, height: 20, width: 20, fit: BoxFit.cover)),
  //       )),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'order_tracking'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel? track;
        if(orderController.trackModel != null) {
          track = orderController.trackModel;


          /*if(_controller != null && GetPlatform.isWeb) {
            if(_track.deliveryAddress != null) {
              _controller.showMarkerInfoWindow(MarkerId('destination'));
            }
            if(_track.store != null) {
              _controller.showMarkerInfoWindow(MarkerId('store'));
            }
            if(_track.deliveryMan != null) {
              _controller.showMarkerInfoWindow(MarkerId('delivery_boy'));
            }
          }*/
        }

        return track != null ? Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Stack(children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(
              double.parse(track.deliveryAddress!.latitude!), double.parse(track.deliveryAddress!.longitude!),
            ), zoom: 16),
            minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
            zoomControlsEnabled: true,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              _isLoading = false;
              setMarker(
                track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                    address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, track.deliveryMan,
                track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                  latitude: Get.find<LocationController>().position.latitude.toString(),
                  longitude: Get.find<LocationController>().position.longitude.toString(),
                  address: Get.find<LocationController>().address,
                ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel', track.moduleType == 'food',
              );
            },
          ),

          /*CustomGoogleMapMarkerBuilder(
            customMarkers: _customMarkers,
            builder: (context, markers) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(target: LatLng(
                  double.parse(track!.deliveryAddress!.latitude!), double.parse(track.deliveryAddress!.longitude!),
                ), zoom: 16),
                minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                zoomControlsEnabled: true,
                markers: markers ?? HashSet(),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                  _isLoading = false;
                  setMarker(
                    track!.orderType == 'parcel' ? Store(latitude: track.receiverDetails!.latitude, longitude: track.receiverDetails!.longitude,
                        address: track.receiverDetails!.address, name: track.receiverDetails!.contactPersonName) : track.store, track.deliveryMan,
                    track.orderType == 'take_away' ? Get.find<LocationController>().position.latitude == 0 ? track.deliveryAddress : AddressModel(
                      latitude: Get.find<LocationController>().position.latitude.toString(),
                      longitude: Get.find<LocationController>().position.longitude.toString(),
                      address: Get.find<LocationController>().address,
                    ) : track.deliveryAddress, track.orderType == 'take_away', track.orderType == 'parcel',
                  );
                },
              );
            },
          ),*/

          _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),

          Positioned(
            top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
            child: TrackingStepperWidget(status: track.orderStatus, takeAway: track.orderType == 'take_away'),
          ),

          Positioned(
            bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
            child: TrackDetailsView(status: track.orderStatus, track: track, callback: () async{
              _timer?.cancel();
              await Get.toNamed(RouteHelper.getChatRoute(
                notificationBody: NotificationBody(deliverymanId: track!.deliveryMan!.id, orderId: int.parse(widget.orderID!)),
                user: User(id: track.deliveryMan!.id, fName: track.deliveryMan!.fName, lName: track.deliveryMan!.lName, image: track.deliveryMan!.image),
              ));
              _startApiCall();
            }),
          ),

        ]))) : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  void setMarker(Store? store, DeliveryMan? deliveryMan, AddressModel? addressModel, bool takeAway, bool parcel, bool isRestaurant) async {
    try {
      Uint8List restaurantImageData = await convertAssetToUnit8List(parcel ? Images.userMarker
          : isRestaurant ? Images.restaurantMarker : Images.markerStore, width: isRestaurant ? 100 : 150);
      Uint8List deliveryBoyImageData = await convertAssetToUnit8List(Images.deliveryManMarker, width: 100);
      Uint8List destinationImageData = await convertAssetToUnit8List(
        takeAway ? Images.myLocationMarker : Images.userMarker,
        width: takeAway ? 50 : 100,
      );

      // Animate to coordinate
      LatLngBounds? bounds;
      double rotation = 0;
      if(_controller != null) {
        if (double.parse(addressModel!.latitude!) < double.parse(store!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
          );
          rotation = 0;
        }else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          );
          rotation = 180;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude)/2,
        (bounds.northeast.longitude + bounds.southwest.longitude)/2,
      );

      _controller!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: centerBounds, zoom: GetPlatform.isWeb ? 10 : 17)));
      if(!ResponsiveHelper.isWeb()) {
        zoomToFit(_controller, bounds, centerBounds, padding: 1.5);
      }

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();
      // _customMarkers = [];
      addressModel != null ? _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
        infoWindow: InfoWindow(
          title: parcel ? 'Sender' : 'Destination',
          snippet: addressModel.address,
        ),
        icon: GetPlatform.isWeb ? BitmapDescriptor.defaultMarker : BitmapDescriptor.fromBytes(destinationImageData),
      )) : const SizedBox();
      /*addressModel != null ? _customMarkers.add(MarkerData(
        marker: Marker(markerId: const MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude!), double.parse(addressModel.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'Sender' : 'Destination',
            snippet: addressModel.address,
          ),
        ),
        child:  GetPlatform.isWeb ? const Icon(Icons.location_on, size: 18) : _customMarker('${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${''}'),
      )) : const SizedBox();*/

      ///store for normal order , but receiver for parcel order
      store != null ? _markers.add(Marker(
        markerId: const MarkerId('store'),
        position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
        infoWindow: InfoWindow(
          title: parcel ? 'Receiver' : Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'store'.tr : 'store'.tr,
          snippet: store.address,
        ),
        icon: GetPlatform.isWeb ? BitmapDescriptor.defaultMarker : BitmapDescriptor.fromBytes(restaurantImageData),
      )) : const SizedBox();

      /*store != null ? _customMarkers.add(MarkerData(
        marker: Marker(markerId: const MarkerId('store'),
          position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'Receiver' : Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'store'.tr : 'store'.tr,
            snippet: store.address,
          ),
        ),
        child: GetPlatform.isWeb ? const Icon(Icons.location_on, size: 18) : _customMarker('${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${store.logo}'),
      )) : const SizedBox();*/

      deliveryMan != null ? _markers.add(Marker(
        markerId: const MarkerId('delivery_boy'),
        position: LatLng(double.parse(deliveryMan.lat ?? '0'), double.parse(deliveryMan.lng ?? '0')),
        infoWindow: InfoWindow(
          title: 'delivery_man'.tr,
          snippet: deliveryMan.location,
        ),
        rotation: rotation,
        icon: GetPlatform.isWeb ? BitmapDescriptor.defaultMarker : BitmapDescriptor.fromBytes(deliveryBoyImageData),
      )) : const SizedBox();

      /*deliveryMan != null ? _customMarkers.add(MarkerData(
        marker: Marker(markerId: const MarkerId('delivery_boy'),
          position: LatLng(double.parse(deliveryMan.lat ?? '0'), double.parse(deliveryMan.lng ?? '0')),
          infoWindow: InfoWindow(
            title: 'delivery_man'.tr,
            snippet: deliveryMan.location,
          ),
        ),
        child: GetPlatform.isWeb ? const Icon(Icons.location_on, size: 18) : _customMarker('${Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${deliveryMan.image}'),
      )) : const SizedBox();*/

    }catch(_) {}
    setState(() {});
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds, LatLng centerBounds, {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while(keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if(fits(bounds!, screenBounds)){
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      }
      else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck = screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck = screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck = screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck = screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck && northEastLongitudeCheck && southWestLatitudeCheck && southWestLongitudeCheck;
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }
}
