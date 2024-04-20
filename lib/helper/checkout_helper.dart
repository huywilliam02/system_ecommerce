import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/coupon_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/parcel_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/cart_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/parcel_category_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/zone_response_model.dart';
import 'package:citgroupvn_ecommerce/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_dropdown.dart';
import 'package:citgroupvn_ecommerce/view/screens/address/widget/address_widget.dart';

class CheckoutHelper {

  static double calculateOriginalDeliveryCharge({required Store? store, required AddressModel address, required double? distance, required double? extraCharge}) {
    double deliveryCharge = -1;

    Pivot? moduleData;
    ZoneData? zoneData;
    if(store != null) {
      for(ZoneData zData in address.zoneData!) {

        for(Modules m in zData.modules!) {
          if(m.id == Get.find<SplashController>().module!.id && m.pivot!.zoneId == store.zoneId) {
            moduleData = m.pivot;
            break;
          }
        }

        if(zData.id == store.zoneId) {
          zoneData = zData;
        }
      }
    }
    double perKmCharge = 0;
    double minimumCharge = 0;
    double? maximumCharge = 0;
    if(store != null && distance != null && distance != -1 && store.selfDeliverySystem == 1) {
      perKmCharge = store.perKmShippingCharge!;
      minimumCharge = store.minimumShippingCharge!;
      maximumCharge = store.maximumShippingCharge;
    }else if(store != null && distance != null && distance != -1) {
      perKmCharge = moduleData!.perKmShippingCharge!;
      minimumCharge = moduleData.minimumShippingCharge!;
      maximumCharge = moduleData.maximumShippingCharge;
    }
    if(store != null && distance != null) {
      deliveryCharge = distance * perKmCharge;

      if(deliveryCharge < minimumCharge) {
        deliveryCharge = minimumCharge;
      }else if(maximumCharge != null && deliveryCharge > maximumCharge) {
        deliveryCharge = maximumCharge;
      }
    }

    if(store != null && store.selfDeliverySystem == 0 && extraCharge != null) {
      deliveryCharge = deliveryCharge + extraCharge;
    }

    if(store != null && store.selfDeliverySystem == 0 && zoneData!.increaseDeliveryFeeStatus == 1) {
      deliveryCharge = deliveryCharge + (deliveryCharge * (zoneData.increaseDeliveryFee!/100));
    }

    return deliveryCharge;
  }

  static double calculateDeliveryCharge({required Store? store, required AddressModel address, required double? distance, required double? extraCharge, required double orderAmount, required String orderType}) {
    double deliveryCharge = calculateOriginalDeliveryCharge(store: store, address: address, distance: distance, extraCharge: extraCharge);

    if (orderType == 'take_away' || (store != null && store.freeDelivery!)
        || (Get.find<SplashController>().configModel!.freeDeliveryOver != null && orderAmount
            >= Get.find<SplashController>().configModel!.freeDeliveryOver!)
        || Get.find<CouponController>().freeDelivery || (Get.find<AuthController>().isGuestLoggedIn() && (Get.find<OrderController>().guestAddress == null && Get.find<OrderController>().orderType != 'take_away'))) {
      deliveryCharge = 0;
    }

    return PriceConverter.toFixed(deliveryCharge);
  }

  static List<DropdownItem<int>> getDropdownAddressList({required BuildContext context, required List<AddressModel>? addressList, required Store? store}) {
    List<DropdownItem<int>> dropDownAddressList = [];

    dropDownAddressList.add(DropdownItem<int>(value: 0, child: SizedBox(
      width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth - 50 : context.width - 50,
      child: AddressWidget(
        address: Get.find<LocationController>().getUserAddress(),
        fromAddress: false, fromCheckout: true,
      ),
    )));

    if(addressList != null && store != null) {
      for(int index=0; index<addressList.length; index++) {
        if(addressList[index].zoneIds!.contains(store.zoneId)) {

          dropDownAddressList.add(DropdownItem<int>(value: index + 1, child: SizedBox(
            width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
            child: AddressWidget(
              address: addressList[index],
              fromAddress: false, fromCheckout: true,
            ),
          )));
        }
      }
    }
    return dropDownAddressList;
  }

  static List<AddressModel> getAddressList({required List<AddressModel>? addressList, required Store? store, }) {
    List<AddressModel> address = [];

    address.add(Get.find<LocationController>().getUserAddress()!);

    if(addressList != null && store != null) {
      for(int index=0; index<addressList.length; index++) {
        if(addressList[index].zoneIds!.contains(store.zoneId)) {
          address.add(addressList[index]);
        }
      }
    }
    return address;
  }

  static Pivot? getModuleData({required Store? store}) {
    Pivot? moduleData;
    if(store != null) {
      for(ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
        for(Modules m in zData.modules!) {
          if(m.id == Get.find<SplashController>().module!.id && m.pivot!.zoneId == store.zoneId) {
            moduleData = m.pivot;
            break;
          }
        }
      }
    }
    return moduleData;
  }

  static bool checkCODActive({required Store? store}) {
    bool isCashOnDeliveryActive = false;
    if(store != null){
      for(ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
        if(zData.id ==  store.zoneId) {
          isCashOnDeliveryActive = zData.cashOnDelivery! && Get.find<SplashController>().configModel!.cashOnDelivery!;
        }
      }
    }
    return isCashOnDeliveryActive;
  }

  static bool checkDigitalPaymentActive({required Store? store}) {
    bool isDigitalPaymentActive = false;
    if(store != null){
      for(ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
        if(zData.id ==  store.zoneId) {
          isDigitalPaymentActive = zData.digitalPayment! && Get.find<SplashController>().configModel!.digitalPayment!;
        }
      }
    }
    return isDigitalPaymentActive;
  }

  static double calculateAddonsPrice({required Store? store, required List<CartModel?>? cartList}) {
    double addOns = 0;
    if(store != null && cartList != null) {
      for (var cartModel in cartList) {
        List<AddOns> addOnList = [];
        for (var addOnId in cartModel!.addOnIds!) {
          for (AddOns addOns in cartModel.item!.addOns!) {
            if (addOns.id == addOnId.id) {
              addOnList.add(addOns);
              break;
            }
          }
        }
        for (int index = 0; index < addOnList.length; index++) {
          addOns = addOns + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
        }
      }
    }
    return PriceConverter.toFixed(addOns);


  }

  static double calculateVariationPrice({required Store? store, required List<CartModel?>? cartList, bool calculateDiscount = false, bool calculateWithoutDiscount = false}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if(store != null && cartList != null) {
      for (var cartModel in cartList) {
        double? discount = cartModel!.item!.storeDiscount == 0 ? cartModel.item!.discount : cartModel.item!.storeDiscount;
        String? discountType = cartModel.item!.storeDiscount == 0 ? cartModel.item!.discountType : 'percent';

        if(Get.find<SplashController>().getModuleConfig(cartModel.item!.moduleType).newVariation!) {
          for(int index = 0; index< cartModel.item!.foodVariations!.length; index++) {
            for(int i=0; i<cartModel.item!.foodVariations![index].variationValues!.length; i++) {
              if(cartModel.foodVariations![index][i]!) {
                variationPrice += (PriceConverter.convertWithDiscount(cartModel.item!.foodVariations![index].variationValues![i].optionPrice!, discount, discountType)! * cartModel.quantity!);
                variationDiscount += (cartModel.item!.foodVariations![index].variationValues![i].optionPrice! * cartModel.quantity!);
              }
            }
          }
        } else {

          String variationType = '';
          for(int i=0; i<cartModel.variation!.length; i++) {
            variationType = cartModel.variation![i].type!;
          }

          if(cartModel.item!.variations!.isNotEmpty) {
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                variationPrice += (variation.price! * cartModel.quantity!);
                break;
              }
            }
          } else {
            variationDiscount += (PriceConverter.convertWithDiscount(cartModel.item!.price!, discount, discountType)! * cartModel.quantity!);
            variationPrice += (cartModel.item!.price! * cartModel.quantity!);
          }

        }
      }
    }
    if(calculateDiscount) {
      return (variationDiscount - variationPrice);
    } else if(calculateWithoutDiscount) {
      return variationDiscount;
    } else {
      return variationPrice;
    }
  }

  static double calculatePrice({required Store? store, required List<CartModel?>? cartList}) {
    double price = 0;
    if(cartList != null) {
      for (var cartModel in cartList) {
        if(Get.find<SplashController>().getModuleConfig(cartModel!.item!.moduleType).newVariation!){
          price = price + (cartModel.item!.price! * cartModel.quantity!);
        } else {
          price = calculateVariationPrice(store: store, cartList: cartList);
        }
      }
    }
    return PriceConverter.toFixed(price);
  }

  static double calculateDiscount({required Store? store, required List<CartModel?>? cartList, required double price, required double addOns}) {
    double discount = 0;
    if (store != null && cartList != null) {
      for (var cartModel in cartList) {
        double? dis = (store.discount != null
            && DateConverter.isAvailable(store.discount!.startTime, store.discount!.endTime))
            && cartModel!.item!.flashSale != 1
            ? store.discount!.discount : cartModel!.item!.discount;
        String? disType = (store.discount != null
            && DateConverter.isAvailable(store.discount!.startTime, store.discount!.endTime))
            && cartModel.item!.flashSale != 1
            ? 'percent' : cartModel.item!.discountType;
        if(Get.find<SplashController>().getModuleConfig(cartModel.item!.moduleType).newVariation!) {
          double d = ((cartModel.item!.price! - PriceConverter.convertWithDiscount(cartModel.item!.price!, dis, disType)!) * cartModel.quantity!);
          discount = discount + d;
          discount = discount + calculateVariationPrice(store: store, cartList: cartList, calculateDiscount: true);
        } else {
          String variationType = '';
          double variationPrice = 0;
          double variationWithoutDiscountPrice = 0;
          for(int i=0; i<cartModel.variation!.length; i++) {
            variationType = cartModel.variation![i].type!;
          }
          if(cartModel.item!.variations!.isNotEmpty){
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                variationPrice += (PriceConverter.convertWithDiscount(variation.price!, dis, disType)! * cartModel.quantity!);
                variationWithoutDiscountPrice += (variation.price! * cartModel.quantity!);
                break;
              }
            }
            discount = discount + (variationWithoutDiscountPrice - variationPrice);

          } else {
            double d = ((cartModel.item!.price! - PriceConverter.convertWithDiscount(cartModel.item!.price!, dis, disType)!) * cartModel.quantity!);
            discount = discount + d;
          }

        }
      }
    }

    // discount = discount + calculateVariationPrice(store: store, cartList: cartList, calculateDiscount: true);

    if (store != null && store.discount != null) {
      if (store.discount!.maxDiscount != 0 && store.discount!.maxDiscount! < discount) {
        discount = store.discount!.maxDiscount!;
      }
      if (store.discount!.minPurchase != 0 && store.discount!.minPurchase! > (price + addOns)) {
        discount = 0;
      }
    }
    return PriceConverter.toFixed(discount);
  }

  static double calculateTax({required bool taxIncluded, required double orderAmount, required double? taxPercent}) {
    double tax = 0;
    if(taxIncluded){
      tax = orderAmount * taxPercent! /(100 + taxPercent);
    }else{
      tax = PriceConverter.calculation(orderAmount, taxPercent, 'percent', 1);
    }
    return PriceConverter.toFixed(tax);
  }

  static double calculateTotal({
    required double subTotal, required double deliveryCharge, required double discount,
    required double couponDiscount, required bool taxIncluded, required double tax,
    required String orderType, required double tips, required double additionalCharge,
  }) {

    // print('------total checkout : $subTotal + $deliveryCharge - $discount - $couponDiscount + ${(taxIncluded ? 0 : tax)}'
    //     '+ ${((orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? tips : 0)} + $additionalCharge');

    return PriceConverter.toFixed(
        subTotal + deliveryCharge - discount- couponDiscount + (taxIncluded ? 0 : tax)
        + ((orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? tips : 0)
        + additionalCharge
    );
  }

  static bool checkZoneOfflinePaymentOnOff({required AddressModel? addressModel}) {
    bool? status = false;
    ZoneData? zoneData;
    for (var data in addressModel!.zoneData!) {
      if(data.id == addressModel.zoneId){
        zoneData = data;
        break;
      }
    }
    status = zoneData?.offlinePayment ?? false;
    return status;
  }

  static double calculateSubTotal({required double price, required double addOns, required double variations, required List<CartModel?>? cartList}) {
    double subTotal = 0;
    bool isFoodVariation = false;

    if(cartList != null && cartList.isNotEmpty) {
      isFoodVariation = Get.find<SplashController>().getModuleConfig(cartList[0]!.item!.moduleType).newVariation!;
    }
    if(isFoodVariation){
      subTotal = price + addOns + variations;
    } else {
      subTotal = price;
    }

    return subTotal;
  }

  static double calculateOrderAmount({required double price, required double variations, required double discount, required double addOns, required double couponDiscount, required List<CartModel?>? cartList}) {
    double orderAmount = 0;
    double variationPrice = 0;
    if(cartList != null && cartList.isNotEmpty && Get.find<SplashController>().getModuleConfig(cartList[0]?.item?.moduleType).newVariation!){
      variationPrice = variations;
    }
    orderAmount = (price + variationPrice - discount) + addOns - couponDiscount;
    return PriceConverter.toFixed(orderAmount);
  }

  static double calculateParcelDeliveryCharge({required ParcelController parcelController, required ParcelCategoryModel parcelCategory, required int zoneId}) {
    double charge = 0;
    ZoneData? zoneData;
    for(ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
      if(zData.id == zoneId) {
        zoneData = zData;
      }
    }

    if(parcelController.distance != -1 && parcelController.extraCharge != null) {
      double parcelPerKmShippingCharge = parcelCategory.parcelPerKmShippingCharge! > 0
          ? parcelCategory.parcelPerKmShippingCharge!
          : Get.find<SplashController>().configModel!.parcelPerKmShippingCharge!;
      double parcelMinimumShippingCharge = parcelCategory.parcelMinimumShippingCharge! > 0
          ? parcelCategory.parcelMinimumShippingCharge!
          : Get.find<SplashController>().configModel!.parcelMinimumShippingCharge!;
      charge = parcelController.distance! * parcelPerKmShippingCharge;
      if (charge < parcelMinimumShippingCharge) {
        charge = parcelMinimumShippingCharge;
      }

      if (parcelController.extraCharge != null) {
        charge = charge + parcelController.extraCharge!;
      }

      if (zoneData!.increaseDeliveryFeeStatus == 1) {
        charge = charge + (charge * (zoneData.increaseDeliveryFee! / 100));
      }
    }

    return PriceConverter.toFixed(charge);
  }

}