import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/parcel_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/zone_response_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/my_text_field.dart';
import 'package:citgroupvn_ecommerce/view/base/text_field_shadow.dart';
import 'package:citgroupvn_ecommerce/view/screens/location/pick_map_screen.dart';
import 'package:citgroupvn_ecommerce/view/screens/location/widget/serach_location_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/parcel/widget/address_dialog.dart';
class ParcelView extends StatefulWidget {
  final bool isSender ;
  final Widget bottomButton;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final TextEditingController floorController;

  const ParcelView({
    Key? key, required this.isSender, required this.nameController, required this.phoneController,
    required this.streetController, required this.houseController, required this.floorController, required this.bottomButton
  }) : super(key: key);

  @override
  State<ParcelView> createState() => _ParcelViewState();
}

class _ParcelViewState extends State<ParcelView> {
  ScrollController scrollController = ScrollController();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: Dimensions.webMaxWidth, child: GetBuilder<ParcelController>(builder: (parcelController) {

        return SingleChildScrollView(
          controller: ScrollController(),
          child: Center(child: FooterView(
            child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),

                SearchLocationWidget(
                  mapController: null,
                  pickedAddress: parcelController.isSender ? parcelController.pickupAddress!.address : parcelController.destinationAddress != null ? parcelController.destinationAddress!.address : '',
                  isEnabled: widget.isSender ? parcelController.isPickedUp : !parcelController.isPickedUp!,
                  isPickedUp: parcelController.isSender,
                  hint: parcelController.isSender ? 'pick_up'.tr : 'destination'.tr,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(children: [
                  Expanded(flex: 4,
                    child: CustomButton(
                      buttonText: 'set_from_map'.tr,
                      onPressed: () {
                        if(ResponsiveHelper.isDesktop(Get.context)){
                          showGeneralDialog(context: context, pageBuilder: (_,__,___) {
                            return SizedBox(
                                height: 300, width: 300,
                                child: PickMapScreen(fromSignUp: false, canRoute: false, fromAddAddress: false, route:'', onPicked: (AddressModel address) async {
                                  if(parcelController.isPickedUp!) {
                                    parcelController.setPickupAddress(address, true);
                                  }else {
                                    ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);
                                    AddressModel a = AddressModel(
                                      id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
                                      address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
                                      zoneIds: address.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
                                    );
                                    parcelController.setDestinationAddress(a);
                                  }
                                }),
                            );
                          });
                        }else{
                          Get.toNamed(RouteHelper.getPickMapRoute('parcel', false), arguments: PickMapScreen(
                            fromSignUp: false, fromAddAddress: false, canRoute: false, route: '', onPicked: (AddressModel address) async {

                            if(parcelController.isPickedUp!) {
                              parcelController.setPickupAddress(address, true);
                            }else {
                              ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(address.latitude.toString(), address.longitude.toString(), false);
                              AddressModel a = AddressModel(
                                id: address.id, addressType: address.addressType, contactPersonNumber: address.contactPersonNumber, contactPersonName: address.contactPersonName,
                                address: address.address, latitude: address.latitude, longitude: address.longitude, zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
                                zoneIds: address.zoneIds, method: address.method, streetNumber: address.streetNumber, house: address.house, floor: address.floor,
                              );
                              parcelController.setDestinationAddress(a);
                            }
                          },
                          ));
                        }
                      }
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(flex: 6,
                      child: InkWell(
                        onTap: (){
                          if(Get.find<AuthController>().isLoggedIn()) {
                            Get.dialog(AddressDialog(onTap: (AddressModel address) {
                              widget.streetController.text = address.streetNumber ?? '';
                              widget.houseController.text = address.house ?? '';
                              widget.floorController.text = address.floor ?? '';
                            }));
                          }else {
                            showCustomSnackBar('you_are_not_logged_in'.tr);
                          }
                        },
                        child: Container(
                          height: ResponsiveHelper.isDesktop(context) ? 44 : 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
                          child: Center(child: Text('set_from_saved_address'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge))),
                        ),
                      )
                  ),
                ]),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                Column(children: [

                  Center(child: Text(parcelController.isSender ? 'sender_information'.tr : 'receiver_information'.tr, style: robotoMedium)),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  TextFieldShadow(
                    child: MyTextField(
                      hintText: parcelController.isSender ? 'sender_name'.tr : 'receiver_name'.tr,
                      inputType: TextInputType.name,
                      controller: widget.nameController,
                      focusNode: _nameNode,
                      nextFocus: _phoneNode,
                      capitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  TextFieldShadow(
                    child: MyTextField(
                      hintText: parcelController.isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
                      inputType: TextInputType.phone,
                      focusNode: _phoneNode,
                      nextFocus: _streetNode,
                      controller: widget.phoneController,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                ]),

                Column(children: [

                  Center(child: Text(parcelController.isSender ? 'pickup_information'.tr : 'destination_information'.tr, style: robotoMedium)),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  TextFieldShadow(
                    child: MyTextField(
                      hintText: "${'street_number'.tr} (${'optional'.tr})",
                      inputType: TextInputType.streetAddress,
                      focusNode: _streetNode,
                      nextFocus: _houseNode,
                      controller: widget.streetController,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Row(children: [
                    Expanded(
                      child: TextFieldShadow(
                        child: MyTextField(
                          hintText: "${'house'.tr} (${'optional'.tr})",
                          inputType: TextInputType.text,
                          focusNode: _houseNode,
                          nextFocus: _floorNode,
                          controller: widget.houseController,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: TextFieldShadow(
                        child: MyTextField(
                          hintText: "${'floor'.tr} (${'optional'.tr})",
                          inputType: TextInputType.text,
                          focusNode: _floorNode,
                          inputAction: TextInputAction.done,
                          controller: widget.floorController,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                ]),

                ResponsiveHelper.isDesktop(context) ? widget.bottomButton : const SizedBox(),

              ]),
            )),
          )),
        );
        }
      ),
    );
  }
}
