import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_dropdown.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_text_field.dart';
import 'package:citgroupvn_ecommerce/view/screens/address/widget/address_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/guest_delivery_address.dart';
class DeliverySection extends StatelessWidget {
  final OrderController orderController;
  final StoreController storeController;
  final List<AddressModel> address;
  final List<DropdownItem<int>> addressList;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  const DeliverySection({
    Key? key, required this.orderController, required this.storeController,
    required this.address, required this.addressList, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode,
    required this.guestEmailController, required this.guestEmailNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    bool takeAway = (orderController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Column(children: [
      isGuestLoggedIn ? GuestDeliveryAddress(
        orderController: orderController, storeController: storeController, guestNumberNode: guestNumberNode,
        guestNameTextEditingController: guestNameTextEditingController, guestNumberTextEditingController: guestNumberTextEditingController,
        guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
      ) : !takeAway ? Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('deliver_to'.tr, style: robotoMedium),
            TextButton.icon(
              onPressed: () async {
                var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, false, storeController.store!.zoneId));
                if(address != null) {
                  orderController.getDistanceInKM(
                    LatLng(double.parse(address.latitude), double.parse(address.longitude)),
                    LatLng(double.parse(storeController.store!.latitude!), double.parse(storeController.store!.longitude!)),
                  );
                  orderController.streetNumberController.text = address.streetNumber ?? '';
                  orderController.houseController.text = address.house ?? '';
                  orderController.floorController.text = address.floor ?? '';
                }
              },
              icon: const Icon(Icons.add, size: 20),
              label: Text('add_new'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            ),
          ]),


          isDesktop ?  Stack(children: [
            Container(
              constraints: const BoxConstraints(minHeight:  90),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeExtraSmall,
                  horizontal: Dimensions.paddingSizeExtraSmall,
                ),
                child: AddressWidget(
                  address: address[orderController.addressIndex!],
                  fromAddress: false, fromCheckout: true,
                ),
              ),
            ),

            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton(
                    position: PopupMenuPosition.under,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onSelected: (value) {},
                    itemBuilder: (context)  => List.generate(
                        address.length, (index) => PopupMenuItem(
                      child: InkWell(
                        onTap: () {
                          orderController.getDistanceInKM(
                            LatLng(
                              double.parse(address[index].latitude!),
                              double.parse(address[index].longitude!),
                            ),
                            LatLng(double.parse(storeController.store!.latitude!), double.parse(storeController.store!.longitude!)),
                          );
                          orderController.setAddressIndex(index);
                          orderController.streetNumberController.text = address[orderController.addressIndex!].streetNumber ?? '';
                          orderController.houseController.text = address[orderController.addressIndex!].house ?? '';
                          orderController.floorController.text = address[orderController.addressIndex!].floor ?? '';
                          Navigator.pop(context);
                        },
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 20, width: 20,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: orderController.addressIndex == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                                ),
                                child: orderController.addressIndex == index ? Container(
                                  height: 15, width: 15,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                                ) : const SizedBox(),
                              ),

                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(address[index].addressType!.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    Text(
                                      address[index].address!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                      ),
                    )
                    )
                ),
              ),
            ),
          ]) : Container(
            constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? 90 : 75),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: CustomDropdown<int>(

              onChange: (int? value, int index) {
                orderController.getDistanceInKM(
                  LatLng(
                    double.parse(address[index].latitude!),
                    double.parse(address[index].longitude!),
                  ),
                  LatLng(double.parse(storeController.store!.latitude!), double.parse(storeController.store!.longitude!)),
                );
                orderController.setAddressIndex(index);

                orderController.streetNumberController.text = address[orderController.addressIndex!].streetNumber ?? '';
                orderController.houseController.text = address[orderController.addressIndex!].house ?? '';
                orderController.floorController.text = address[orderController.addressIndex!].floor ?? '';

              },
              dropdownButtonStyle: DropdownButtonStyle(
                height: 45,
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeExtraSmall,
                  horizontal: Dimensions.paddingSizeExtraSmall,
                ),
                primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              dropdownStyle: DropdownStyle(
                elevation: 10,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              ),
              items: addressList,
              child: AddressWidget(
                address: address[orderController.addressIndex!],
                fromAddress: false, fromCheckout: true,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          !isDesktop ? CustomTextField(
            hintText: ' ',
            titleText: 'street_number'.tr,
            inputType: TextInputType.streetAddress,
            focusNode: orderController.streetNode,
            nextFocus: orderController.houseNode,
            controller: orderController.streetNumberController,
          ) : const SizedBox(),
          SizedBox(height: !isDesktop ? Dimensions.paddingSizeLarge : 0),

          Row(
              children: [
                isDesktop ? Expanded(
                  child: CustomTextField(
                    showTitle: true,
                    hintText: ' ',
                    titleText: 'street_number'.tr,
                    inputType: TextInputType.streetAddress,
                    focusNode: orderController.streetNode,
                    nextFocus: orderController.houseNode,
                    controller: orderController.streetNumberController,
                  ),
                ) : const SizedBox(),
                SizedBox(width: isDesktop ? Dimensions.paddingSizeSmall : 0),

                Expanded(
                  child: CustomTextField(
                    showTitle: isDesktop,
                    hintText: ' ',
                    titleText: 'house'.tr,
                    inputType: TextInputType.text,
                    focusNode: orderController.houseNode,
                    nextFocus: orderController.floorNode,
                    controller: orderController.houseController,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: CustomTextField(
                    showTitle: isDesktop,
                    hintText: ' ',
                    titleText: 'floor'.tr,
                    inputType: TextInputType.text,
                    focusNode: orderController.floorNode,
                    inputAction: TextInputAction.done,
                    controller: orderController.floorController,
                  ),
                ),
                //const SizedBox(height: Dimensions.paddingSizeLarge),
              ]
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ]),
      ) : const SizedBox(),
    ]);
  }
}
