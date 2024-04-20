import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/body/place_order_body.dart';
import 'package:citgroupvn_ecommerce/data/model/response/cart_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart' as other_variation;
import 'package:citgroupvn_ecommerce/data/model/response/online_cart_model.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';

class CartHelper {

  static List<OrderVariation> getSelectedVariations ({required bool isFoodVariation, required List<FoodVariation>? foodVariations, required List<List<bool?>> selectedVariations}) {
    List<OrderVariation> variations = [];
    if(isFoodVariation) {
      for(int i=0; i<foodVariations!.length; i++) {
        if(selectedVariations[i].contains(true)) {
          variations.add(OrderVariation(name: foodVariations[i].name, values: OrderVariationValue(label: [])));
          for(int j=0; j<foodVariations[i].variationValues!.length; j++) {
            if(selectedVariations[i][j]!) {
              variations[variations.length-1].values!.label!.add(foodVariations[i].variationValues![j].level);
            }
          }
        }
      }
    }
    return variations;
  }

  static getSelectedAddonIds({required List<AddOn> addOnIdList }) {
    List<int?> listOfAddOnId = [];
    for (var addOn in addOnIdList) {
      listOfAddOnId.add(addOn.id);
    }
    return listOfAddOnId;
  }

  static getSelectedAddonQtnList({required List<AddOn> addOnIdList }) {
    List<int?> listOfAddOnQty = [];
    for (var addOn in addOnIdList) {
      listOfAddOnQty.add(addOn.quantity);
    }
    return listOfAddOnQty;
  }

  static List<CartModel> formatOnlineCartToLocalCart({required List<OnlineCartModel> onlineCartModel}) {

    List<CartModel> cartList = [];
    for (OnlineCartModel cart in onlineCartModel) {
      // print('=======caart module type : ${cart.item!.moduleType}');
      double price = cart.item!.price!;
      double? discount = cart.item!.storeDiscount == 0 ? cart.item!.discount! : cart.item!.storeDiscount!;
      String? discountType = (cart.item!.storeDiscount == 0) ? cart.item!.discountType : 'percent';
      double discountedPrice = PriceConverter.convertWithDiscount(price, discount, discountType)!;

      double? discountAmount = price - discountedPrice;
      int? quantity = cart.quantity;
      int? stock = cart.item!.stock ?? 0;

      List<List<bool?>> selectedFoodVariations = [];
      List<bool> collapsVariation = [];

      if(cart.item!.moduleType == 'food'/*Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation ?? false*/) {
        for(int index=0; index<cart.item!.foodVariations!.length; index++) {
          selectedFoodVariations.add([]);
          collapsVariation.add(true);
          for(int i=0; i < cart.item!.foodVariations![index].variationValues!.length; i++) {
            if(cart.item!.foodVariations![index].variationValues![i].isSelected ?? false){
              selectedFoodVariations[index].add(true);
            } else {
              selectedFoodVariations[index].add(false);
            }
          }
        }
      } else {
        String variationType = cart.productVariation != null && cart.productVariation!.isNotEmpty ? cart.productVariation![0].type! : '';
        for (other_variation.Variation variation in cart.item!.variations!) {
          if (variation.type == variationType) {
            discountedPrice = (PriceConverter.convertWithDiscount(variation.price!, discount, discountType)! * cart.quantity!);
            break;
          }
        }
      }

      List<AddOn> addOnIdList = [];
      List<AddOns> addOnsList = [];
      for (int index = 0; index < cart.addOnIds!.length; index++) {
        addOnIdList.add(AddOn(id: cart.addOnIds![index], quantity: cart.addOnQtys![index]));
        for (int i=0; i< cart.item!.addOns!.length; i++) {
          if(cart.addOnIds![index] == cart.item!.addOns![i].id) {
            addOnsList.add(AddOns(id: cart.item!.addOns![i].id, name: cart.item!.addOns![i].name, price: cart.item!.addOns![i].price));
          }
        }
      }

      int? quantityLimit = cart.item!.quantityLimit;

      cartList.add(
        CartModel(
          cart.id, price, discountedPrice, cart.productVariation?? [], selectedFoodVariations, discountAmount, quantity,
          addOnIdList, addOnsList, false, stock, cart.item, quantityLimit,
        ),
      );
    }

    return cartList;
  }

  static double? calculatePriceWithVariation({required Item? item, bool isStartingPrice = true}) {
    double? startingPrice;
    double? endingPrice;

    if(item!.variations!.isNotEmpty) {
      List<double?> priceList = [];
      for (var variation in item.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if(priceList[0]! < priceList[priceList.length-1]!) {
        endingPrice = priceList[priceList.length-1];
      }
    }else {
      startingPrice = item.price;
    }
    if(isStartingPrice) {
      return startingPrice;
    } else {
      return endingPrice;
    }
  }

  static String? setupVariationText({required CartModel cart}) {
    String? variationText = '';

    if(Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation!) {
      if(cart.foodVariations!.isNotEmpty) {
        for(int index=0; index<cart.foodVariations!.length; index++) {
          if(cart.foodVariations![index].contains(true)) {
            variationText = '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${cart.item!.foodVariations![index].name} (';
            for(int i=0; i<cart.foodVariations![index].length; i++) {
              if(cart.foodVariations![index][i]!) {
                variationText = '${variationText!}${variationText.endsWith('(') ? '' : ', '}${cart.item!.foodVariations![index].variationValues![i].level}';
              }
            }
            variationText = '${variationText!})';
          }
        }
      }
    }else {
      if(cart.variation!.isNotEmpty) {
        List<String> variationTypes = cart.variation![0].type!.split('-');
        if(variationTypes.length == cart.item!.choiceOptions!.length) {
          int index0 = 0;
          for (var choice in cart.item!.choiceOptions!) {
            variationText = '${variationText!}${(index0 == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index0]}';
            index0 = index0 + 1;
          }
        }else {
          variationText = cart.item!.variations![0].type;
        }
      }
    }
    return variationText;
  }

  static String? setupAddonsText({required CartModel cart}) {
    String addOnText = '';
    int index0 = 0;
    List<int?> ids = [];
    List<int?> qtys = [];
    for (var addOn in cart.addOnIds!) {
      ids.add(addOn.id);
      qtys.add(addOn.quantity);
    }
    for (var addOn in cart.item!.addOns!) {
      if (ids.contains(addOn.id)) {
        addOnText = '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
        index0 = index0 + 1;
      }
    }
    return addOnText;
  }

  static double getItemDetailsDiscountPrice({required CartModel cart}) {
    double discountedPrice = 0;

    double? discount = cart.item!.storeDiscount == 0 ? cart.item!.discount! : cart.item!.storeDiscount!;
    String? discountType = (cart.item!.storeDiscount == 0) ? cart.item!.discountType : 'percent';
    String variationType = cart.variation != null && cart.variation!.isNotEmpty ? cart.variation![0].type! : '';

    if(cart.variation != null && cart.variation!.isNotEmpty){
      for (other_variation.Variation variation in cart.item!.variations!) {
        if (variation.type == variationType) {
          discountedPrice = (PriceConverter.convertWithDiscount(variation.price!, discount, discountType)! * cart.quantity!);
          break;
        }
      }
    } else {
      discountedPrice = (PriceConverter.convertWithDiscount(cart.item!.price!, discount, discountType)! * cart.quantity!);
    }

    return discountedPrice;
  }

}