import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/parcel_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/my_text_field.dart';
import 'package:citgroupvn_ecommerce/view/base/text_field_shadow.dart';
import 'package:citgroupvn_ecommerce/view/screens/location/pick_map_screen.dart';
import 'package:citgroupvn_ecommerce/view/screens/location/widget/serach_location_widget.dart';
class ReceiverView extends StatefulWidget {
  const ReceiverView({Key? key}) : super(key: key);

  @override
  State<ReceiverView> createState() => _ReceiverViewState();
}

class _ReceiverViewState extends State<ReceiverView> {

  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();


  @override
  void initState() {
    super.initState();

    Get.find<ParcelController>().setPickupAddress(Get.find<LocationController>().getUserAddress(), false);
    Get.find<ParcelController>().setIsPickedUp(false, false);
    if(Get.find<AuthController>().isLoggedIn() && Get.find<LocationController>().addressList == null) {
      Get.find<LocationController>().getAddressList();
    }
    if (Get.find<AuthController>().isLoggedIn() && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streetNumberController.dispose();
    _houseController.dispose();
    _floorController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(width: Dimensions.webMaxWidth, child: GetBuilder<ParcelController>(builder: (parcelController) {

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
          child: Column(children: [
            const SizedBox(height: Dimensions.paddingSizeSmall),

            SearchLocationWidget(
              mapController: null,
              pickedAddress: parcelController.destinationAddress != null ? parcelController.destinationAddress!.address : '',
              isEnabled: !parcelController.isPickedUp!,
              isPickedUp: false,
              hint: 'destination'.tr,
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(children: [
              Expanded(flex: 4,
                child: CustomButton(
                  buttonText: 'set_from_map'.tr,
                  onPressed: () {
                    if(ResponsiveHelper.isDesktop(Get.context)) {
                      showGeneralDialog(context: context, pageBuilder: (_,__,___) {
                        return SizedBox(
                            height: 300, width: 300,
                            child: PickMapScreen(fromSignUp: false, canRoute: false, fromAddAddress: false, route:'', onPicked: (AddressModel address) {
                              if(parcelController.isPickedUp!) {
                                parcelController.setPickupAddress(address, true);
                                _streetNumberController.text = '';
                                _houseController.text = '';
                                _floorController.text = '';
                              }else {
                                parcelController.setDestinationAddress(address);
                              }
                            }
                            ),
                        );
                      });
                    } else {
                      Get.toNamed(RouteHelper.getPickMapRoute('parcel', false), arguments: PickMapScreen(
                        fromSignUp: false, fromAddAddress: false, canRoute: false, route: '', onPicked: (AddressModel address) {
                        if(parcelController.isPickedUp!) {
                          parcelController.setPickupAddress(address, true);
                          _streetNumberController.text = '';
                          _houseController.text = '';
                          _floorController.text = '';
                        }else {
                          parcelController.setDestinationAddress(address);
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
                    onTap: (){},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
                      child: Center(child: Text('set_from_saved_address'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge))),
                    ),
                  )
              ),
            ]),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            Column(children: [

              Center(child: Text('receiver_information'.tr, style: robotoMedium)),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              TextFieldShadow(
                child: MyTextField(
                  hintText: 'receiver_name'.tr,
                  inputType: TextInputType.name,
                  controller: _nameController,
                  focusNode: _nameNode,
                  nextFocus: _phoneNode,
                  capitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              TextFieldShadow(
                child: MyTextField(
                  hintText: 'receiver_phone_number'.tr,
                  inputType: TextInputType.phone,
                  focusNode: _phoneNode,
                  inputAction: TextInputAction.done,
                  controller: _phoneController,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ]),

            Column(children: [

              Center(child: Text('destination_information'.tr, style: robotoMedium)),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              TextFieldShadow(
                child: MyTextField(
                  hintText: "${'street_number'.tr} (${'optional'.tr})",
                  inputType: TextInputType.streetAddress,
                  focusNode: _streetNode,
                  nextFocus: _houseNode,
                  controller: _streetNumberController,
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
                      controller: _houseController,
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
                      controller: _floorController,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ]),



          ]),
        );
      }
      ),
      ),
    );
  }
}
