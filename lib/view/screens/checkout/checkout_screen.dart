import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/cart_controller.dart';
import 'package:citgroupvn_ecommerce/controller/coupon_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/body/place_order_body.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/cart_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/config_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/zone_response_model.dart';
import 'package:citgroupvn_ecommerce/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_dropdown.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/helper/checkout_helper.dart';
import 'package:citgroupvn_ecommerce/view/base/not_logged_in_screen.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/checkout_screen_shimmer_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/payment_method_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/bottom_section.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/top_section.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel?>? cartList;
  final bool fromCart;
  final int? storeId;
  const CheckoutScreen({Key? key, required this.fromCart, required this.cartList, required this.storeId}) : super(key: key);

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {

  final ScrollController _scrollController = ScrollController();
  final JustTheController tooltipController1 = JustTheController();
  final JustTheController tooltipController2 = JustTheController();
  final JustTheController tooltipController3 = JustTheController();

  double? _taxPercent = 0;
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  bool _isOfflinePaymentActive = false;
  List<CartModel?>? _cartList;
  late bool _isWalletActive;

  List<AddressModel> address = [];
  bool canCheckSmall = false;

  final TextEditingController guestContactPersonNameController = TextEditingController();
  final TextEditingController guestContactPersonNumberController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final FocusNode guestNumberNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
      bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
      Get.find<OrderController>().setGuestAddress(null, isUpdate: false);
      Get.find<OrderController>().streetNumberController.text = Get.find<LocationController>().getUserAddress()!.streetNumber ?? '';
      Get.find<OrderController>().houseController.text = Get.find<LocationController>().getUserAddress()!.house ?? '';
      Get.find<OrderController>().floorController.text = Get.find<LocationController>().getUserAddress()!.floor ?? '';
      Get.find<OrderController>().couponController.text = '';

      Get.find<OrderController>().getDmTipMostTapped();
      Get.find<OrderController>().setPreferenceTimeForView('', isUpdate: false);

      Get.find<OrderController>().getOfflineMethodList();

      if(Get.find<OrderController>().isPartialPay){
        Get.find<OrderController>().changePartialPayment(isUpdate: false);
      }

      // Get.find<LocationController>().getZone(
      //     Get.find<LocationController>().getUserAddress()!.latitude,
      //     Get.find<LocationController>().getUserAddress()!.longitude, false, updateInAddress: true
      // );

      if(isLoggedIn) {
        if(Get.find<UserController>().userInfoModel == null) {
          Get.find<UserController>().getUserInfo();
        }

        Get.find<CouponController>().getCouponList();

        if(Get.find<LocationController>().addressList == null) {
          Get.find<LocationController>().getAddressList();
        }
      }

      if(widget.storeId == null){
        _cartList = [];
        if(GetPlatform.isWeb) {
         await Get.find<CartController>().getCartDataOnline();
        }
        widget.fromCart ? _cartList!.addAll(Get.find<CartController>().cartList) : _cartList!.addAll(widget.cartList!);
        if(_cartList != null && _cartList!.isNotEmpty) {
          Get.find<StoreController>().initCheckoutData(_cartList![0]!.item!.storeId);
        }
      }
      if(widget.storeId != null){
        Get.find<StoreController>().initCheckoutData(widget.storeId);
        Get.find<StoreController>().pickPrescriptionImage(isRemove: true, isCamera: false);
        Get.find<CouponController>().removeCouponData(false);
      }
      _isWalletActive = Get.find<SplashController>().configModel!.customerWalletStatus == 1;
      Get.find<OrderController>().updateTips(
        Get.find<AuthController>().getDmTipIndex().isNotEmpty ? int.parse(Get.find<AuthController>().getDmTipIndex()) : 0,
        notify: false,
      );
      Get.find<OrderController>().tipController.text = Get.find<OrderController>().selectedTips != -1 ? AppConstants.tips[Get.find<OrderController>().selectedTips] : '';

  }

  @override
  void dispose() {
    super.dispose();

    guestContactPersonNameController.dispose();
    guestContactPersonNumberController.dispose();
  }


  @override
  Widget build(BuildContext context) {

    Module? module = Get.find<SplashController>().configModel!.moduleConfig!.module;
    bool guestCheckoutPermission = Get.find<AuthController>().isGuestLoggedIn() && Get.find<SplashController>().configModel!.guestCheckoutStatus!;

    return Scaffold(
      appBar: CustomAppBar(title: 'checkout'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: guestCheckoutPermission || Get.find<AuthController>().isLoggedIn() ? GetBuilder<LocationController>(builder: (locationController) {
        return GetBuilder<StoreController>(builder: (storeController) {
          List<DropdownItem<int>> addressList = CheckoutHelper.getDropdownAddressList(context: context, addressList: locationController.addressList, store: storeController.store);
          address = CheckoutHelper.getAddressList(addressList: locationController.addressList, store: storeController.store);

          bool todayClosed = false;
          bool tomorrowClosed = false;
          Pivot? moduleData = CheckoutHelper.getModuleData(store: storeController.store);
          _isCashOnDeliveryActive = CheckoutHelper.checkCODActive(store: storeController.store);
          _isDigitalPaymentActive = CheckoutHelper.checkDigitalPaymentActive(store: storeController.store);
          _isOfflinePaymentActive = Get.find<SplashController>().configModel!.offlinePaymentStatus! && CheckoutHelper.checkZoneOfflinePaymentOnOff(addressModel: Get.find<LocationController>().getUserAddress());
          if(storeController.store != null) {
            todayClosed = storeController.isStoreClosed(true, storeController.store!.active!, storeController.store!.schedules);
            tomorrowClosed = storeController.isStoreClosed(false, storeController.store!.active!, storeController.store!.schedules);
            _taxPercent = storeController.store!.tax;
          }
          return GetBuilder<CouponController>(builder: (couponController) {
            return GetBuilder<OrderController>(builder: (orderController) {
              double? maxCodOrderAmount;

              if(moduleData != null) {
                maxCodOrderAmount = moduleData.maximumCodOrderAmount;
              }
              double price = CheckoutHelper.calculatePrice(store: storeController.store, cartList: _cartList);
              double addOns = CheckoutHelper.calculateAddonsPrice(store: storeController.store, cartList: _cartList);
              double variations = CheckoutHelper.calculateVariationPrice(store: storeController.store, cartList: _cartList, calculateWithoutDiscount: true);
              double? discount = CheckoutHelper.calculateDiscount(
                store: storeController.store, cartList: _cartList, price: price, addOns: addOns,
              );
              double couponDiscount = PriceConverter.toFixed(couponController.discount!);
              bool taxIncluded = Get.find<SplashController>().configModel!.taxIncluded == 1;
              double orderAmount = CheckoutHelper.calculateOrderAmount(
                price: price, variations: variations, discount: discount, addOns: addOns,
                couponDiscount: couponDiscount, cartList: _cartList,
              );
              double tax = CheckoutHelper.calculateTax(
                taxIncluded: taxIncluded, orderAmount: orderAmount, taxPercent: _taxPercent,
              );
              double subTotal = CheckoutHelper.calculateSubTotal(price: price, addOns: addOns, variations: variations, cartList: _cartList);
              double additionalCharge =  Get.find<SplashController>().configModel!.additionalChargeStatus!
                  ? Get.find<SplashController>().configModel!.additionCharge! : 0;
              double originalCharge = CheckoutHelper.calculateOriginalDeliveryCharge(
                store: storeController.store, address: locationController.getUserAddress()!,
                distance: orderController.distance, extraCharge: orderController.extraCharge,
              );
              double deliveryCharge = CheckoutHelper.calculateDeliveryCharge(
                store: storeController.store, address: locationController.getUserAddress()!, distance: orderController.distance,
                extraCharge: orderController.extraCharge, orderType: orderController.orderType!, orderAmount: orderAmount,
              );

              double total = CheckoutHelper.calculateTotal(
                subTotal: subTotal, deliveryCharge: deliveryCharge, discount: discount,
                couponDiscount: couponDiscount, taxIncluded: taxIncluded, tax: tax, orderType: orderController.orderType!,
                tips: orderController.tips, additionalCharge: additionalCharge,
              );

              if(widget.storeId != null){
                orderController.setPaymentMethod(0, isUpdate: false);
              }
              orderController.setTotalAmount(total - (orderController.isPartialPay ? Get.find<UserController>().userInfoModel!.walletBalance! : 0));

              return (orderController.distance != null && storeController.store != null) ? Column(
                children: [
                  ResponsiveHelper.isDesktop(context) ? Container(
                    height: 64,
                    color: Theme.of(context).primaryColor.withOpacity(0.10),
                    child: Center(child: Text('checkout'.tr, style: robotoMedium)),
                  ) : const SizedBox(),

                  Expanded(child: Scrollbar(controller: _scrollController, child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: FooterView(child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: ResponsiveHelper.isDesktop(context) ? Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Expanded(flex: 6, child: TopSection(
                            storeController: storeController, charge: originalCharge, deliveryCharge: deliveryCharge,
                            orderController: orderController, locationController: locationController, addressList: addressList,
                            tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, module : module, price: price,
                            discount: discount, addOns: addOns, address: address, cartList: _cartList, isCashOnDeliveryActive: _isCashOnDeliveryActive!,
                            isDigitalPaymentActive: _isDigitalPaymentActive!, isWalletActive: _isWalletActive, storeId: widget.storeId,
                            total: total, isOfflinePaymentActive: _isOfflinePaymentActive, guestNameTextEditingController: guestContactPersonNameController,
                            guestNumberTextEditingController: guestContactPersonNumberController, guestNumberNode: guestNumberNode,
                            guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                            tooltipController1: tooltipController1, tooltipController2: tooltipController2, dmTipsTooltipController: tooltipController3,
                          )),
                          const SizedBox(width: Dimensions.paddingSizeLarge),

                          Expanded(flex: 4, child: BottomSection(
                              orderController: orderController, total: total, module: module!, subTotal: subTotal,
                              discount: discount, couponController: couponController, taxIncluded: taxIncluded, tax: tax,
                              deliveryCharge: deliveryCharge, storeController: storeController, locationController: locationController,
                              todayClosed: todayClosed,tomorrowClosed: tomorrowClosed, orderAmount: orderAmount,
                              maxCodOrderAmount: maxCodOrderAmount, storeId: widget.storeId, taxPercent: _taxPercent, price: price, addOns : addOns,
                              checkoutButton: _orderPlaceButton(
                                  orderController, storeController, locationController, todayClosed, tomorrowClosed,
                                  orderAmount, deliveryCharge, tax, discount, total, maxCodOrderAmount,
                              ),
                          )),
                        ]),
                      ) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        TopSection(
                          storeController: storeController, charge: originalCharge, deliveryCharge: deliveryCharge,
                          orderController: orderController, locationController: locationController, addressList: addressList,
                          tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, module : module, price: price,
                          discount: discount, addOns: addOns, address: address, cartList: _cartList, isCashOnDeliveryActive: _isCashOnDeliveryActive!,
                          isDigitalPaymentActive: _isDigitalPaymentActive!, isWalletActive: _isWalletActive, storeId: widget.storeId,
                          total: total, isOfflinePaymentActive: _isOfflinePaymentActive, guestNameTextEditingController: guestContactPersonNameController,
                          guestNumberTextEditingController: guestContactPersonNumberController, guestNumberNode: guestNumberNode,
                          guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                          tooltipController1: tooltipController1, tooltipController2: tooltipController2, dmTipsTooltipController: tooltipController3,
                        ),

                        BottomSection(
                          orderController: orderController, total: total, module: module!, subTotal: subTotal,
                          discount: discount, couponController: couponController, taxIncluded: taxIncluded, tax: tax,
                          deliveryCharge: deliveryCharge, storeController: storeController, locationController: locationController,
                          todayClosed: todayClosed,tomorrowClosed: tomorrowClosed, orderAmount: orderAmount,
                          maxCodOrderAmount: maxCodOrderAmount, storeId: widget.storeId, taxPercent: _taxPercent, price: price, addOns : addOns,
                          checkoutButton: _orderPlaceButton(
                            orderController, storeController, locationController, todayClosed, tomorrowClosed,
                            orderAmount, deliveryCharge, tax, discount, total, maxCodOrderAmount,
                          ),
                        )
                      ]),
                    )),
                  ))),

                  ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(
                              orderController.isPartialPay ? 'due_payment'.tr : 'total_amount'.tr,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            ),
                            PriceConverter.convertAnimationPrice(
                              orderController.viewTotalPrice,
                              textStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            ),
                            // Text(
                            //   PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
                            //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            // ),
                          ]),
                        ),

                        _orderPlaceButton(
                            orderController, storeController, locationController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge, tax, discount, total, maxCodOrderAmount
                        ),
                      ],
                    ),
                  ),

                ],
              ) : const CheckoutScreenShimmerView();
            });
          });
        });
      }) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }


  Widget _orderPlaceButton(OrderController orderController, StoreController storeController, LocationController locationController, bool todayClosed, bool tomorrowClosed,
      double orderAmount, double? deliveryCharge, double tax, double? discount, double total, double? maxCodOrderAmount) {
    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
      child: SafeArea(
        child: CustomButton(
          isLoading: orderController.isLoading,
          buttonText: orderController.isPartialPay ? 'place_order'.tr : 'confirm_order'.tr,
          onPressed: orderController.acceptTerms ? () {
          bool isAvailable = true;
          DateTime scheduleStartDate = DateTime.now();
          DateTime scheduleEndDate = DateTime.now();
          bool isGuestLogIn = Get.find<AuthController>().isGuestLoggedIn();
          if(orderController.timeSlots == null || orderController.timeSlots!.isEmpty) {
            isAvailable = false;
          }else {
            DateTime date = orderController.selectedDateSlot == 0 ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
            DateTime startTime = orderController.timeSlots![orderController.selectedTimeSlot].startTime!;
            DateTime endTime = orderController.timeSlots![orderController.selectedTimeSlot].endTime!;
            scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute+1);
            scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);
            if(_cartList != null){
              for (CartModel? cart in _cartList!) {
                if (!DateConverter.isAvailable(
                  cart!.item!.availableTimeStarts, cart.item!.availableTimeEnds,
                  time: storeController.store!.scheduleOrder! ? scheduleStartDate : null,
                ) && !DateConverter.isAvailable(
                  cart.item!.availableTimeStarts, cart.item!.availableTimeEnds,
                  time: storeController.store!.scheduleOrder! ? scheduleEndDate : null,
                )) {
                  isAvailable = false;
                  break;
                }
              }
            }
          }

          if(isGuestLogIn && orderController.guestAddress == null && orderController.orderType != 'take_away') {
            showCustomSnackBar('please_setup_your_delivery_address_first'.tr);
          } else if(isGuestLogIn && orderController.orderType == 'take_away' && guestContactPersonNameController.text.isEmpty) {
            showCustomSnackBar('please_enter_contact_person_name'.tr);
          } else if(isGuestLogIn && orderController.orderType == 'take_away' && guestContactPersonNumberController.text.isEmpty) {
            showCustomSnackBar('please_enter_contact_person_number'.tr);
          } else if(!_isCashOnDeliveryActive! && !_isDigitalPaymentActive! && !_isWalletActive) {
            showCustomSnackBar('no_payment_method_is_enabled'.tr);
          }else if(orderController.paymentMethodIndex == -1) {
            if(ResponsiveHelper.isDesktop(context)){
              Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
                isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                isWalletActive: _isWalletActive, storeId: widget.storeId, totalPrice: total, isOfflinePaymentActive: _isOfflinePaymentActive,
              )));
            }else{
              showModalBottomSheet(
                context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                builder: (con) => PaymentMethodBottomSheet(
                  isCashOnDeliveryActive: _isCashOnDeliveryActive!, isDigitalPaymentActive: _isDigitalPaymentActive!,
                  isWalletActive: _isWalletActive, storeId: widget.storeId, totalPrice: total, isOfflinePaymentActive: _isOfflinePaymentActive,
                ),
              );
            }
          } else if(orderAmount < storeController.store!.minimumOrder! && widget.storeId == null) {
            showCustomSnackBar('${'minimum_order_amount_is'.tr} ${storeController.store!.minimumOrder}');
          }else if(orderController.tipController.text.isNotEmpty && orderController.tipController.text != 'not_now' && double.parse(orderController.tipController.text.trim()) < 0) {
            showCustomSnackBar('tips_can_not_be_negative'.tr);
          }else if((orderController.selectedDateSlot == 0 && todayClosed) || (orderController.selectedDateSlot == 1 && tomorrowClosed)) {
            showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr);
          }else if(orderController.paymentMethodIndex == 0 && _isCashOnDeliveryActive! && maxCodOrderAmount != null && maxCodOrderAmount != 0 && (total > maxCodOrderAmount) && widget.storeId == null){
            showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
          }else if(orderController.paymentMethodIndex != 0 && widget.storeId != null){
            showCustomSnackBar('payment_method_is_not_available'.tr);
          }else if (orderController.timeSlots == null || orderController.timeSlots!.isEmpty) {
            if(storeController.store!.scheduleOrder!) {
              showCustomSnackBar('select_a_time'.tr);
            }else {
              showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                  ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr);
            }
          }else if (!isAvailable) {
            showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
          }else if (orderController.orderType != 'take_away' && orderController.distance == -1 && deliveryCharge == -1) {
            showCustomSnackBar('delivery_fee_not_set_yet'.tr);
          }else if (widget.storeId != null && storeController.pickedPrescriptions.isEmpty) {
            showCustomSnackBar('please_upload_your_prescription_images'.tr);
          }else if (!orderController.acceptTerms) {
            showCustomSnackBar('please_accept_privacy_policy_trams_conditions_refund_policy_first'.tr);
          }
          else {

            AddressModel? finalAddress = isGuestLogIn ? orderController.guestAddress : address[orderController.addressIndex!];

            if(isGuestLogIn && orderController.orderType == 'take_away') {
              String number = orderController.countryDialCode! + guestContactPersonNumberController.text;
              finalAddress = AddressModel(contactPersonName: guestContactPersonNameController.text, contactPersonNumber: number,
                address: Get.find<LocationController>().getUserAddress()!.address!, latitude: Get.find<LocationController>().getUserAddress()!.latitude,
                longitude: Get.find<LocationController>().getUserAddress()!.longitude, zoneId: Get.find<LocationController>().getUserAddress()!.zoneId,
                email: guestEmailController.text,
              );
            }

            if(!isGuestLogIn && finalAddress!.contactPersonNumber == 'null'){
              finalAddress.contactPersonNumber = Get.find<UserController>().userInfoModel!.phone;
            }

            if(widget.storeId == null){

              List<OnlineCart> carts = [];
              for (int index = 0; index < _cartList!.length; index++) {
                CartModel cart = _cartList![index]!;
                List<int?> addOnIdList = [];
                List<int?> addOnQtyList = [];
                for (var addOn in cart.addOnIds!) {
                  addOnIdList.add(addOn.id);
                  addOnQtyList.add(addOn.quantity);
                }

                List<OrderVariation> variations = [];
                if(Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation!) {
                  for(int i=0; i<cart.item!.foodVariations!.length; i++) {
                    if(cart.foodVariations![i].contains(true)) {
                      variations.add(OrderVariation(name: cart.item!.foodVariations![i].name, values: OrderVariationValue(label: [])));
                      for(int j=0; j<cart.item!.foodVariations![i].variationValues!.length; j++) {
                        if(cart.foodVariations![i][j]!) {
                          variations[variations.length-1].values!.label!.add(cart.item!.foodVariations![i].variationValues![j].level);
                        }
                      }
                    }
                  }
                }
                carts.add(OnlineCart(
                  cart.id, cart.item!.id, cart.isCampaign! ? cart.item!.id : null,
                  cart.discountedPrice.toString(), '',
                  Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation! ? null : cart.variation,
                  Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation! ? variations : null,
                  cart.quantity, addOnIdList, cart.addOns, addOnQtyList, 'Item', itemType: !widget.fromCart ? "App\Models\ItemCampaign" : null,
                ));
              }

              PlaceOrderBody placeOrderBody = PlaceOrderBody(
                cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: orderController.distance,
                scheduleAt: !storeController.store!.scheduleOrder! ? null : (orderController.selectedDateSlot == 0
                    && orderController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleEndDate),
                orderAmount: total, orderNote: Get.find<OrderController>().noteController.text, orderType: orderController.orderType,
                paymentMethod: orderController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                    : orderController.paymentMethodIndex == 1 ? 'wallet'
                    : orderController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
                couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
                    && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
                storeId: _cartList![0]!.item!.storeId,
                address: finalAddress!.address, latitude: finalAddress.latitude, longitude: finalAddress.longitude, addressType: finalAddress.addressType,
                contactPersonName: finalAddress.contactPersonName ?? '${Get.find<UserController>().userInfoModel!.fName} '
                    '${Get.find<UserController>().userInfoModel!.lName}',
                contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<UserController>().userInfoModel!.phone,
                streetNumber: isGuestLogIn ? finalAddress.streetNumber??'' : orderController.streetNumberController.text.trim(),
                house: isGuestLogIn ? finalAddress.house??'' : orderController.houseController.text.trim(),
                floor: isGuestLogIn ? finalAddress.floor??'' : orderController.floorController.text.trim(),
                discountAmount: discount, taxAmount: tax, receiverDetails: null, parcelCategoryId: null,
                chargePayer: null, dmTips: (orderController.orderType == 'take_away' || orderController.tipController.text == 'not_now') ? '' : orderController.tipController.text.trim(),
                cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
                unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
                deliveryInstruction: orderController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[orderController.selectedInstruction] : '',
                partialPayment: orderController.isPartialPay ? 1 : 0, guestId: isGuestLogIn ? int.parse(Get.find<AuthController>().getGuestId()) : 0,
                isBuyNow: widget.fromCart ? 0 : 1, guestEmail: isGuestLogIn ? finalAddress.email : null,
              );

              if(orderController.paymentMethodIndex == 3){
                Get.toNamed(RouteHelper.getOfflinePaymentScreen(placeOrderBody: placeOrderBody, zoneId: storeController.store!.zoneId!, total: /*total*/ orderController.viewTotalPrice!, maxCodOrderAmount: maxCodOrderAmount, fromCart: widget.fromCart, isCodActive: _isCashOnDeliveryActive, forParcel: false));
              } else {
                orderController.placeOrder(placeOrderBody, storeController.store!.zoneId, total, maxCodOrderAmount, widget.fromCart, _isCashOnDeliveryActive!);
              }
            }else{

              orderController.placePrescriptionOrder(widget.storeId, storeController.store!.zoneId, orderController.distance,
                  finalAddress!.address!, finalAddress.longitude!, finalAddress.latitude!, orderController.noteController.text,
                  storeController.pickedPrescriptions, (orderController.orderType == 'take_away' || orderController.tipController.text == 'not_now')
                      ? '' : orderController.tipController.text.trim(), orderController.selectedInstruction != -1
                      ? AppConstants.deliveryInstructionList[orderController.selectedInstruction] : '', 0, 0, widget.fromCart, _isCashOnDeliveryActive!
              );
            }

          }
        } : null),
      ),
    );
  }
}