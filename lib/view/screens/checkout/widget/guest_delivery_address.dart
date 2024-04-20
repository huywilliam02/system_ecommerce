import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_text_field.dart';
import 'package:citgroupvn_ecommerce/view/screens/address/add_address_screen.dart';
class GuestDeliveryAddress extends StatelessWidget {
  final OrderController orderController;
  final StoreController storeController;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  const GuestDeliveryAddress({
    Key? key, required this.orderController, required this.storeController, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode,
    required this.guestEmailController, required this.guestEmailNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool takeAway = (orderController.orderType == 'take_away');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [
        Row(children: [
          Image.asset(Images.truck, height: 14, width: 14, color: Theme.of(context).primaryColor),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Text(takeAway ? 'contact_information'.tr : 'delivery_information'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
          const Spacer(),

          takeAway ? const SizedBox() : InkWell(
            onTap: () async {
              var address = await Get.toNamed(RouteHelper.getEditAddressRoute(orderController.guestAddress, fromGuest: true));

              // var address ;
              // // if(ResponsiveHelper.isDesktop(context)) {
              // if(ResponsiveHelper.isDesktop(context)) {
              //   showGeneralDialog(context: context, pageBuilder: (_,__,___) {
              //     return SizedBox(
              //       height: 300, width: 300,
              //       child: AddAddressScreen(
              //         fromCheckout: true, fromRide: false, zoneId: storeController.store!.zoneId, forGuest: true,
              //         address: orderController.guestAddress,
              //       ),
              //     );
              //   }).then((value) {
              //     address = value;
              //   });
              // } else {
              //   address = await Get.toNamed(RouteHelper.getEditAddressRoute(orderController.guestAddress, fromGuest: true));
              // }
              /*} else {
                address = await Get.to(() => AddAddressScreen(
                  fromCheckout: true, fromRide: false, zoneId: storeController.store!.zoneId, forGuest: true,
                  address: orderController.guestAddress,
                ));
              }*/

              if(address != null) {
                orderController.setGuestAddress(address);
                orderController.getDistanceInKM(
                  LatLng(double.parse(address.latitude), double.parse(address.longitude)),
                  LatLng(double.parse(storeController.store!.latitude!), double.parse(storeController.store!.longitude!)),
                );
              }
            },
            child: Image.asset(Images.editDelivery, height: 20, width: 20, color: Theme.of(context).primaryColor),
          ),
        ]),

        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
          child: Divider(color: Theme.of(context).disabledColor),
        ),

        takeAway ? Column(children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomTextField(
            showTitle: ResponsiveHelper.isDesktop(context),
            titleText: 'contact_person_name'.tr,
            hintText: ' ',
            inputType: TextInputType.name,
            controller: guestNameTextEditingController,
            nextFocus: guestNumberNode,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomTextField(
            showTitle: ResponsiveHelper.isDesktop(context),
            titleText: 'contact_person_number'.tr,
            hintText: ' ',
            controller: guestNumberTextEditingController,
            focusNode: guestNumberNode,
            nextFocus: guestEmailNode,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: (CountryCode countryCode) {
              orderController.countryDialCode = countryCode.dialCode;
            },
            countryDialCode: orderController.countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomTextField(
            titleText: 'email'.tr,
            hintText: 'enter_email'.tr,
            controller: guestEmailController,
            focusNode: guestEmailNode,
            inputAction: TextInputAction.done,
            inputType: TextInputType.emailAddress,
            prefixIcon: Icons.mail,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

        ]) : orderController.guestAddress == null ? InkWell(
          onTap: (){},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
            child: Column(children: [
              Image.asset(Images.truck, height: 20, width: 20, color: Theme.of(context).disabledColor),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text('please_update_your_delivery_info'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),
            ]),
          ),
        ) : Column(children: [
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Row(children: [
            Icon(Icons.location_on, size: 16, color: Theme.of(context).primaryColor.withOpacity(0.5)),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Flexible(child: Text(
              orderController.guestAddress!.address!,
              style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis,
            )),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(children: [
              addressInfo('address_type'.tr, orderController.guestAddress!.addressType!),
              addressInfo('name'.tr, orderController.guestAddress!.contactPersonName!),
              addressInfo('phone'.tr, orderController.guestAddress!.contactPersonNumber!),
              addressInfo('email'.tr, orderController.guestAddress!.email!),
            ])),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              addressInfo('street'.tr, orderController.guestAddress!.streetNumber!),
              addressInfo('house'.tr, orderController.guestAddress!.house!),
              addressInfo('floor'.tr, orderController.guestAddress!.floor!),
            ])),
          ])
        ]),

      ]),
    );
  }

  Widget addressInfo(String key, String value) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(children: [
        Text('$key: ', style: robotoRegular.copyWith(color: Theme.of(Get.context!).disabledColor)),
        Flexible(child: Text(value, style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
