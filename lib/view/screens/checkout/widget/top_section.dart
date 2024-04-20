import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/cart_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/config_model.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_dropdown.dart';
import 'package:citgroupvn_ecommerce/view/screens/cart/widget/delivery_option_button.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/coupon_section.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/delivery_instruction_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/delivery_section.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/deliveryman_tips_section.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/partial_pay_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/payment_section.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/time_slot_section.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/web_delivery_instruction_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/widget/camera_button_sheet.dart';
import 'dart:io';

class TopSection extends StatelessWidget {
  final StoreController storeController;
  final double  charge;
  final double deliveryCharge;
  final OrderController orderController;
  final LocationController locationController;
  final List<DropdownItem<int>> addressList;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  final  double price;
  final double discount;
  final double addOns;
  final int? storeId;
  final List<AddressModel> address;
  final List<CartModel?>? cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final bool isOfflinePaymentActive;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final JustTheController tooltipController1;
  final JustTheController tooltipController2;
  final JustTheController dmTipsTooltipController;

  const TopSection({
    Key? key, required this.deliveryCharge, required  this.charge, required this.tomorrowClosed,
    required this.todayClosed, required this.price, required this.discount, required this.addOns,
    required this.addressList, required this.storeController, required this.orderController,
    required this.locationController, this.module, this.storeId, required this.address, required this.cartList,
    required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive, required this.isWalletActive,
    required this.total, required this.isOfflinePaymentActive, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode,
    required this.guestEmailController, required this.guestEmailNode, required this.tooltipController1,
    required this.tooltipController2, required this.dmTipsTooltipController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool takeAway = (orderController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();

    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      child: Column(children: [

        storeId != null ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              Text('your_prescription'.tr, style: robotoMedium),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: tooltipController1,
                preferredDirection: AxisDirection.right,
                tailLength: 14,
                tailBaseWidth: 20,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('prescription_tool_tip'.tr, style: robotoRegular.copyWith(color: Colors.white)),
                ),
                child: InkWell(
                  onTap: () => tooltipController1.showTooltip(),
                  child: const Icon(Icons.info_outline),
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: storeController.pickedPrescriptions.length+1,
                itemBuilder: (context, index) {
                  XFile? file = index == storeController.pickedPrescriptions.length ? null : storeController.pickedPrescriptions[index];
                  if(index < 5 && index == storeController.pickedPrescriptions.length) {
                    return InkWell(
                      onTap: () {
                        if(ResponsiveHelper.isDesktop(context)){
                          storeController.pickPrescriptionImage(isRemove: false, isCamera: false);
                        }else{
                          Get.bottomSheet(const CameraButtonSheet());
                        }
                      },
                      child: DottedBorder(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 1,
                        strokeCap: StrokeCap.butt,
                        dashPattern: const [5, 5],
                        padding: const EdgeInsets.all(0),
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(Dimensions.radiusDefault),
                        child: Container(
                          height: 98, width: 98, alignment: Alignment.center, decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                          child:  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.cloud_upload, color: Theme.of(context).disabledColor, size: 32),
                            Text('upload_your_prescription'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center,),
                          ]),
                        ),
                      ),
                    );
                  }
                  return file != null ? Container(
                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: DottedBorder(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1,
                      strokeCap: StrokeCap.butt,
                      dashPattern: const [5, 5],
                      padding: const EdgeInsets.all(0),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(Dimensions.radiusDefault),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: GetPlatform.isWeb ? Image.network(
                              file.path, width: 98, height: 98, fit: BoxFit.cover,
                            ) : Image.file(
                              File(file.path), width: 98, height: 98, fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0, top: 0,
                            child: InkWell(
                              onTap: () => storeController.removePrescriptionImage(index),
                              child: const Padding(
                                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Icon(Icons.delete_forever, color: Colors.red),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ) : const SizedBox();
                },
              ),
            ),
          ]),
        ) : const SizedBox(),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // delivery option
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          width: double.infinity,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('delivery_type'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              storeId != null ? DeliveryOptionButton(
                value: 'delivery', title: 'home_delivery'.tr, charge: charge,
                isFree: storeController.store!.freeDelivery, fromWeb: true, total: total,
              ) : SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                Get.find<SplashController>().configModel!.homeDeliveryStatus == 1 && storeController.store!.delivery! ? DeliveryOptionButton(
                  value: 'delivery', title: 'home_delivery'.tr, charge: charge,
                  isFree: storeController.store!.freeDelivery,  fromWeb: true, total: total,
                ) : const SizedBox(),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Get.find<SplashController>().configModel!.takeawayStatus == 1 && storeController.store!.takeAway! ? DeliveryOptionButton(
                  value: 'take_away', title: 'take_away'.tr, charge: deliveryCharge, isFree: true,  fromWeb: true, total: total,
                ) : const SizedBox(),
              ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        ///Delivery_fee
        !takeAway && !isGuestLoggedIn ? Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${'delivery_charge'.tr}: '),
          Text(
            storeController.store!.freeDelivery! ? 'free'.tr
                : orderController.distance != -1 ? PriceConverter.convertPrice(charge) : 'calculating'.tr,
            textDirection: TextDirection.ltr,
          ),
        ])) : const SizedBox(),
        SizedBox(height: !takeAway && !isGuestLoggedIn ? Dimensions.paddingSizeLarge : 0),

        ///delivery section
        DeliverySection(orderController: orderController, storeController: storeController, address: address, addressList: addressList,
          guestNameTextEditingController: guestNameTextEditingController, guestNumberTextEditingController: guestNumberTextEditingController,
          guestNumberNode: guestNumberNode, guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
        ),

        SizedBox(height: !takeAway ? isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall : 0),

        ///delivery instruction
        !takeAway ? isDesktop ? const WebDeliveryInstructionView() : const DeliveryInstructionView() : const SizedBox(),

        SizedBox(height: !takeAway ? Dimensions.paddingSizeSmall : 0),

        /// Time Slot
        TimeSlotSection(
          storeId: storeId, storeController: storeController, cartList: cartList, tooltipController2: tooltipController2,
          tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, module: module, orderController: orderController,
        ),

        /// Coupon..
        !isDesktop && !isGuestLoggedIn ? CouponSection(
          storeId: storeId, orderController: orderController, total: total, price: price,
          discount: discount, addOns: addOns, deliveryCharge: deliveryCharge,
        ) : const SizedBox(),

        ///DmTips..
        DeliveryManTipsSection(
          takeAway: takeAway, tooltipController3: dmTipsTooltipController,
          totalPrice: total, onTotalChange: (double price) => total + price, storeId: storeId,
        ),

        ///Payment..
        Container(
          decoration: isDesktop ? const BoxDecoration() : BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeLarge),
          child: Column(children: [

            PaymentSection(
              storeId: storeId, isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
              isWalletActive: isWalletActive, total: total, orderController: orderController, isOfflinePaymentActive: isOfflinePaymentActive,
            ),
            SizedBox(height: isGuestLoggedIn ? 0 : Dimensions.paddingSizeLarge),

            !isDesktop && !isGuestLoggedIn ? PartialPayView(totalPrice: total, isPrescription: storeId != null) : const SizedBox(),

          ]),
        ),
        SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : 0),


      ]),
    );
  }
}
