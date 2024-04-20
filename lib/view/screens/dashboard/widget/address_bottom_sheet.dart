import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/zone_response_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_loader.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/screens/address/widget/address_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/location/pick_map_screen.dart';
class AddressBottomSheet extends StatelessWidget {
  final bool fromDialog;
  const AddressBottomSheet({Key? key, this.fromDialog = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(Get.find<LocationController>().addressList == null){
      Get.find<LocationController>().getAddressList();
    }
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius : BorderRadius.only(
            topLeft: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraLarge),
            topRight : Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraLarge),
            bottomLeft: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : 0),
            bottomRight: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : 0),
          ),
      ),
      child: GetBuilder<LocationController>(
        builder: (locationController) {
          AddressModel? selectedAddress = locationController.getUserAddress();
          return Column(mainAxisSize: MainAxisSize.min, children: [

            fromDialog ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Get.find<SplashController>().saveWebSuggestedLocationStatus(true);
                    Get.back();
                    },
                  icon: const Icon(Icons.clear),
                )
              ]
            ) : const SizedBox(),

            fromDialog ? const SizedBox() : Center(
              child: Container(
                margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
                height: 3, width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                ),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: fromDialog ? 50 : Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  Text('${'hey_welcome_back'.tr}\n${'which_location_do_you_want_to_select'.tr}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Center(
                    child: locationController.addressList != null && locationController.addressList!.isEmpty ? Column(mainAxisSize: MainAxisSize.max,crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Image.asset(Images.noAddress, width: fromDialog ? 180 : 150),

                      fromDialog ? const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),
                      SizedBox(
                        width: 280,
                        child: Text(
                          'you_dont_have_any_saved_address_yet'.tr, textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),
                      ),

                    ]) : const SizedBox(),
                  ),

                  locationController.addressList != null && locationController.addressList!.isEmpty
                      ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                  (locationController.addressList != null && fromDialog) ? const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),
                  Align(
                    alignment: locationController.addressList != null && locationController.addressList!.isEmpty && !fromDialog ? Alignment.center : Alignment.topCenter,
                    child: TextButton.icon(
                      onPressed: (){
                        Get.find<LocationController>().checkPermission(() async {
                          Get.dialog(const CustomLoader(), barrierDismissible: false);
                          AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
                          ZoneResponseModel response = await locationController.getZone(address.latitude, address.longitude, false);
                          if(response.isSuccess) {
                            if(ResponsiveHelper.isDesktop(Get.context)) {
                              Get.find<SplashController>().saveWebSuggestedLocationStatus(true);
                            }
                            locationController.saveAddressAndNavigate(
                              address, false, '', false, ResponsiveHelper.isDesktop(Get.context),
                            );
                          }else {
                            Get.back();
                            if(ResponsiveHelper.isDesktop(Get.context)) {
                              Get.find<SplashController>().saveWebSuggestedLocationStatus(true);
                              showGeneralDialog(context: Get.context!, pageBuilder: (_,__,___) {
                                return const SizedBox(
                                    height: 300, width: 300,
                                    child: PickMapScreen(fromSignUp: false, canRoute: false, fromAddAddress: true, route: null),
                                );
                              });
                            }else {
                              Get.toNamed(RouteHelper.getPickMapRoute(RouteHelper.accessLocation, false));
                            }
                            showCustomSnackBar('service_not_available_in_current_location'.tr);
                          }
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault))),
                        fixedSize: const Size(200, 40),
                          backgroundColor: locationController.addressList != null && locationController.addressList!.isEmpty
                        ? Theme.of(context).primaryColor : Colors.transparent,
                      ),
                      icon:  Icon( Icons.my_location, color: locationController.addressList != null && locationController.addressList!.isEmpty
                          ? Theme.of(context).cardColor : Theme.of(context).primaryColor),
                      label: Text('use_current_location'.tr, style: fromDialog ? robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: locationController.addressList != null && locationController.addressList!.isEmpty
                          ? Theme.of(context).cardColor : Theme.of(context).primaryColor) : robotoMedium.copyWith(color: locationController.addressList != null && locationController.addressList!.isEmpty
                          ? Theme.of(context).cardColor : Theme.of(context).primaryColor)),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  locationController.addressList != null ? locationController.addressList!.isNotEmpty ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: locationController.addressList!.length > 5 ? 5 : locationController.addressList!.length,
                      itemBuilder: (context, index) {
                        bool selected = false;
                        if(selectedAddress!.id == locationController.addressList![index].id){
                          selected = true;
                        }
                        return Center(child: SizedBox(width: 700, child: AddressWidget(
                          address: locationController.addressList![index],
                          fromAddress: false, isSelected: selected, fromDashBoard: true,
                          onTap: () {
                            Get.dialog(const CustomLoader(), barrierDismissible: false);
                            AddressModel address = locationController.addressList![index];
                            locationController.saveAddressAndNavigate(
                              address, false, null, false, ResponsiveHelper.isDesktop(context),
                            );

                            Get.find<SplashController>().saveWebSuggestedLocationStatus(true);
                          },
                        )));
                      },
                    ),
                  ) : const SizedBox() : const Center(child: CircularProgressIndicator()),

                  SizedBox(height: locationController.addressList != null && locationController.addressList!.isEmpty ? 0 : Dimensions.paddingSizeSmall),

                  locationController.addressList != null && locationController.addressList!.isNotEmpty ? TextButton.icon(
                    onPressed: () {
                      Get.find<SplashController>().saveWebSuggestedLocationStatus(true);
                      Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0));
                    },
                    icon: const Icon(Icons.add_circle_outline_sharp),
                    label: Text('add_new_address'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                  ) : const SizedBox(),

                ]),
              ),
            ),
          ]);
        }
      ),
    );
  }
}
