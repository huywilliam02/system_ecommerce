import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/cart_controller.dart';
import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/body/place_order_body.dart';
import 'package:citgroupvn_ecommerce/data/model/response/cart_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/helper/cart_helper.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/cart_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/confirmation_dialog.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/checkout_screen.dart';
import 'package:citgroupvn_ecommerce/view/screens/item/widget/details_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/screens/item/widget/details_web_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/item/widget/item_image_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/item/widget/item_title_view.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Item? item;
  final bool inStorePage;
  const ItemDetailsScreen({Key? key, required this.item, required this.inStorePage}) : super(key: key);

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final Size size = Get.size;
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final GlobalKey<DetailsAppBarState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    Get.find<ItemController>().getProductDetails(widget.item!);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (cartController) {
        return GetBuilder<ItemController>(
          builder: (itemController) {
            int? stock = 0;
            CartModel? cartModel;
            OnlineCart? cart;
            double priceWithAddons = 0;
            int? cartId = cartController.getCartId(itemController.cartIndex);
            if(itemController.item != null && itemController.variationIndex != null){
              List<String> variationList = [];
              for (int index = 0; index < itemController.item!.choiceOptions!.length; index++) {
                variationList.add(itemController.item!.choiceOptions![index].options![itemController.variationIndex![index]].replaceAll(' ', ''));
              }
              String variationType = '';
              bool isFirst = true;
              for (var variation in variationList) {
                if (isFirst) {
                  variationType = '$variationType$variation';
                  isFirst = false;
                } else {
                  variationType = '$variationType-$variation';
                }
              }

              double? price = itemController.item!.price;
              Variation? variation;
              stock = itemController.item!.stock ?? 0;
              for (Variation v in itemController.item!.variations!) {
                if (v.type == variationType) {
                  price = v.price;
                  variation = v;
                  stock = v.stock;
                  break;
                }
              }

              double? discount = (itemController.item!.availableDateStarts != null || itemController.item!.storeDiscount == 0) ? itemController.item!.discount : itemController.item!.storeDiscount;
              String? discountType = (itemController.item!.availableDateStarts != null || itemController.item!.storeDiscount == 0) ? itemController.item!.discountType : 'percent';
              double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;
              double priceWithQuantity = priceWithDiscount * itemController.quantity!;
              double addonsCost = 0;
              List<AddOn> addOnIdList = [];
              List<AddOns> addOnsList = [];
              for (int index = 0; index < itemController.item!.addOns!.length; index++) {
                if (itemController.addOnActiveList[index]) {
                  addonsCost = addonsCost + (itemController.item!.addOns![index].price! * itemController.addOnQtyList[index]!);
                  addOnIdList.add(AddOn(id: itemController.item!.addOns![index].id, quantity: itemController.addOnQtyList[index]));
                  addOnsList.add(itemController.item!.addOns![index]);
                }
              }

              cartModel = CartModel(
                  null, price, priceWithDiscount, variation != null ? [variation] : [], [],
                  (price! - PriceConverter.convertWithDiscount(price, discount, discountType)!),
                  itemController.quantity, addOnIdList, addOnsList, itemController.item!.availableDateStarts != null, stock, itemController.item,
                  itemController.item!.quantityLimit != null ? itemController.item!.quantityLimit! : null
              );

              List<int?> listOfAddOnId = CartHelper.getSelectedAddonIds(addOnIdList: addOnIdList);
              List<int?> listOfAddOnQty = CartHelper.getSelectedAddonQtnList(addOnIdList: addOnIdList);

              cart = OnlineCart(
                  cartId, widget.item!.id, null, priceWithDiscount.toString(), '',
                  variation != null ? [variation] : [], null,
                  itemController.cartIndex != -1 ? cartController.cartList[itemController.cartIndex].quantity
                      : itemController.quantity, listOfAddOnId, addOnsList, listOfAddOnQty, 'Item'
              );
              priceWithAddons = priceWithQuantity + (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? addonsCost : 0);
            }

            return Scaffold(
              key: _globalKey,
              backgroundColor: Theme.of(context).cardColor,
              endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
              appBar: ResponsiveHelper.isDesktop(context)? const CustomAppBar(title: '')  :  DetailsAppBar(key: _key),

              body: SafeArea(child: (itemController.item != null) ? ResponsiveHelper.isDesktop(context) ? DetailsWebView(
                cartModel: cartModel, stock: stock, priceWithAddOns: priceWithAddons, cart: cart,
              ) : Column(children: [
                Expanded(child: Scrollbar(child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    physics: const BouncingScrollPhysics(),
                    child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ItemImageView(item: itemController.item),
                        const SizedBox(height: 20),

                        Builder(
                            builder: (context) {
                              return ItemTitleView(
                                item: itemController.item, inStorePage: widget.inStorePage, isCampaign: itemController.item!.availableDateStarts != null,
                                inStock: (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0),
                              );
                            }
                        ),
                        const Divider(height: 20, thickness: 2),

                        // Variation
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: itemController.item!.choiceOptions!.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(itemController.item!.choiceOptions![index].title!, style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: (1 / 0.25),
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: itemController.item!.choiceOptions![index].options!.length,
                                itemBuilder: (context, i) {
                                  return InkWell(
                                    onTap: () {
                                      itemController.setCartVariationIndex(index, i, itemController.item);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                      decoration: BoxDecoration(
                                        color: itemController.variationIndex![index] != i ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(5),
                                        border: itemController.variationIndex![index] != i ? Border.all(color: Theme.of(context).disabledColor, width: 2) : null,
                                      ),
                                      child: Text(
                                        itemController.item!.choiceOptions![index].options![i].trim(), maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style:robotoRegular.copyWith(
                                          color: itemController.variationIndex![index] != i ? Colors.black : Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: index != itemController.item!.choiceOptions!.length-1 ? Dimensions.paddingSizeLarge : 0),
                            ]);
                          },
                        ),
                        itemController.item!.choiceOptions!.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                        // Quantity
                        GetBuilder<CartController>(
                          builder: (cartController) {
                            return Row(children: [
                              Text('quantity'.tr, style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const Expanded(child: SizedBox()),
                              Container(
                                decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(5)),
                                child: Row(children: [
                                  InkWell(
                                    onTap: cartController.isLoading ? null : () {
                                      if(itemController.cartIndex != -1) {
                                        if(cartController.cartList[itemController.cartIndex].quantity! > 1) {
                                          cartController.setQuantity(false, itemController.cartIndex, stock, cartController.cartList[itemController.cartIndex].quantity);
                                        }
                                      }else {
                                        if(itemController.quantity! > 1) {
                                          itemController.setQuantity(false, stock, itemController.item!.quantityLimit);
                                        }
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                      child: Icon(Icons.remove, size: 20),
                                    ),
                                  ),

                                  !cartController.isLoading ? Text(
                                    itemController.cartIndex != -1 ? cartController.cartList[itemController.cartIndex].quantity.toString()
                                        : itemController.quantity.toString(),
                                    style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                                  ) : const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()),

                                  InkWell(
                                    onTap: cartController.isLoading ? null : () => itemController.cartIndex != -1
                                        ? cartController.setQuantity(true, itemController.cartIndex, stock, cartController.cartList[itemController.cartIndex].quantityLimit)
                                        : itemController.setQuantity(true, stock, itemController.item!.quantityLimit),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                      child: Icon(Icons.add, size: 20),
                                    ),
                                  ),
                                ]),
                              ),
                            ]);
                          }
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Row(children: [
                          Text('${'total_amount'.tr}:', style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text(
                            PriceConverter.convertPrice(itemController.cartIndex != -1
                                ? CartHelper.getItemDetailsDiscountPrice(cart: Get.find<CartController>().cartList[itemController.cartIndex])
                                : priceWithAddons), textDirection: TextDirection.ltr,
                            style:robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                          ),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                        (itemController.item!.description != null && itemController.item!.description!.isNotEmpty) ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('description'.tr, style: robotoMedium),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            Text(itemController.item!.description!, style: robotoRegular),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                          ],
                        ) : const SizedBox(),
                      ],
                    )))),
                )),

                GetBuilder<CartController>(
                  builder: (cartController) {
                    return Container(
                      width: 1170,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: CustomButton(
                        isLoading: cartController.isLoading,
                        buttonText: (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0) ? 'out_of_stock'.tr
                            : itemController.item!.availableDateStarts != null ? 'order_now'.tr : itemController.cartIndex != -1 ? 'update_in_cart'.tr : 'add_to_cart'.tr,
                        onPressed: (!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0) ?  () async {
                          if(!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0) {
                            if(itemController.item!.availableDateStarts != null) {
                              Get.toNamed(RouteHelper.getCheckoutRoute('campaign'), arguments: CheckoutScreen(
                                storeId: null, fromCart: false, cartList: [cartModel],
                              ));
                            }else {
                              if (cartController.existAnotherStoreItem(cartModel!.item!.storeId, Get.find<SplashController>().module == null ? Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id)) {
                                Get.dialog(ConfirmationDialog(
                                  icon: Images.warning,
                                  title: 'are_you_sure_to_reset'.tr,
                                  description: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                                      ? 'if_you_continue'.tr : 'if_you_continue_without_another_store'.tr,
                                  onYesPressed: () {
                                    Get.back();
                                    cartController.clearCartOnline().then((success) async {
                                      if(success) {
                                        await cartController.addToCartOnline(cart!);
                                        itemController.setExistInCart(widget.item);
                                        showCartSnackBar();
                                      }
                                    });

                                  },
                                ), barrierDismissible: false);
                              } else {
                                if(itemController.cartIndex == -1) {
                                  await cartController.addToCartOnline(cart!).then((success) {
                                    if(success){
                                      itemController.setExistInCart(widget.item);
                                      showCartSnackBar();
                                      _key.currentState!.shake();
                                    }
                                  });
                                } else {
                                  await cartController.updateCartOnline(cart!).then((success) {
                                    if(success) {
                                      showCartSnackBar();
                                      _key.currentState!.shake();
                                    }
                                  });
                                }

                              }
                            }
                          }
                        } : null,
                      ),
                    );
                  }
                ),

              ]) : const Center(child: CircularProgressIndicator())),
            );
          },
        );
      }
    );
  }
}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int? quantity;
  final bool isCartWidget;
  final int? stock;
  final bool isExistInCart;
  final int cartIndex;
  final int? quantityLimit;
  final CartController cartController;
  const QuantityButton({Key? key, 
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.isExistInCart,
    required this.cartIndex,
    this.isCartWidget = false,
    this.quantityLimit,
    required this.cartController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cartController.isLoading ? null : () {
        if(isExistInCart) {
          if (!isIncrement && quantity! > 1) {
            Get.find<CartController>().setQuantity(false, cartIndex, stock, quantityLimit);
          } else if (isIncrement && quantity! > 0) {
            if(quantity! < stock! || !Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!) {
              Get.find<CartController>().setQuantity(true, cartIndex, stock, quantityLimit);
            }else {
              showCustomSnackBar('out_of_stock'.tr);
            }
          }
        } else {
          if (!isIncrement && quantity! > 1) {
            Get.find<ItemController>().setQuantity(false, stock, quantityLimit);
          } else if (isIncrement && quantity! > 0) {
            if(quantity! < stock! || !Get.find<SplashController>().configModel!.moduleConfig!.module!.stock!) {
              Get.find<ItemController>().setQuantity(true, stock, quantityLimit);
            }else {
              showCustomSnackBar('out_of_stock'.tr);
            }
          }

        }
      },
      child: Container(
        height: 30, width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (quantity! == 1 && !isIncrement) || cartController.isLoading ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
        ),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: isIncrement ? Colors.white : quantity! == 1 ? Colors.black : Colors.white,
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ),
    );
  }
}
