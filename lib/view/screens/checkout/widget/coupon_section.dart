import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/coupon_controller.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/coupon_bottom_sheet.dart';
class CouponSection extends StatelessWidget {
  final int? storeId;
  final OrderController orderController;
  final double total;
  final double price;
  final double discount;
  final double addOns;
  final double deliveryCharge;
  const CouponSection({Key? key, this.storeId, required this.orderController, required this.total, required this.price, required this.discount, required this.addOns, required this.deliveryCharge, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalPrice = total;
    return storeId == null ? GetBuilder<CouponController>(
      builder: (couponController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Column(children: [

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('promo_code'.tr, style: robotoMedium),
              InkWell(
                onTap: () {

                  if(ResponsiveHelper.isDesktop(context)){
                    Get.dialog(Dialog(child: CouponBottomSheet(storeId: Get.find<StoreController>().store!.id))).then((value) {
                      if(value != null) {
                        orderController.couponController.text = value.toString();
                      }
                    });
                  }else{
                    showModalBottomSheet(
                      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                      builder: (con) => CouponBottomSheet(storeId: Get.find<StoreController>().store!.id),
                    ).then((value) async {
                      if(value != null){
                        if(value != null) {
                          orderController.couponController.text = value.toString();
                        }
                        if(orderController.couponController.text.isNotEmpty){
                          if(Get.find<CouponController>().discount! < 1 && !Get.find<CouponController>().freeDelivery) {
                            if(orderController.couponController.text.isNotEmpty && !Get.find<CouponController>().isLoading) {
                              Get.find<CouponController>().applyCoupon(orderController.couponController.text, (price-discount)+addOns, deliveryCharge,
                                  Get.find<StoreController>().store!.id).then((discount) {
                                if (discount! > 0) {
                                  orderController.couponController.text = 'coupon_applied'.tr;
                                  showCustomSnackBar(
                                    '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                    isError: false,
                                  );
                                  if(orderController.isPartialPay || orderController.paymentMethodIndex == 1) {
                                    totalPrice = totalPrice - discount;
                                    orderController.checkBalanceStatus(totalPrice, 0);
                                  }
                                }
                              });
                            } else if(orderController.couponController.text.isEmpty) {
                              showCustomSnackBar('enter_a_coupon_code'.tr);
                            }
                          } else {
                            Get.find<CouponController>().removeCouponData(true);
                            orderController.couponController.text = '';
                          }
                        }

                      }

                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(children: [
                    Text('add_voucher'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                  ]),
                ),
              )
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).primaryColor, width: 0.2),
              ),
              padding: const EdgeInsets.only(left: 5),
              child: Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: orderController.couponController,
                      style: robotoRegular.copyWith(height: ResponsiveHelper.isMobile(context) ? null : 2),
                      decoration: InputDecoration(
                        hintText: 'enter_promo_code'.tr,
                        hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                        isDense: true,
                        filled: true,
                        enabled: couponController.discount == 0,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                            right: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all( 15),
                          child: Image.asset(Images.couponIcon, height: 10, width: 20, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if(orderController.couponController.text.isNotEmpty){
                      if(Get.find<CouponController>().discount! < 1 && !Get.find<CouponController>().freeDelivery) {
                        if(orderController.couponController.text.isNotEmpty && !Get.find<CouponController>().isLoading) {
                          Get.find<CouponController>().applyCoupon(orderController.couponController.text, (price-discount)+addOns, deliveryCharge,
                              Get.find<StoreController>().store!.id).then((discount) {
                            if (discount! > 0) {
                              orderController.couponController.text = 'coupon_applied'.tr;
                              showCustomSnackBar(
                                '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                isError: false,
                              );
                              if(orderController.isPartialPay || orderController.paymentMethodIndex == 1) {
                                totalPrice = totalPrice - discount;
                                orderController.checkBalanceStatus(totalPrice, discount);
                              }
                            }
                          });
                        } else if(orderController.couponController.text.isEmpty) {
                          showCustomSnackBar('enter_a_coupon_code'.tr);
                        }
                      } else {
                        totalPrice = totalPrice + couponController.discount!;
                        Get.find<CouponController>().removeCouponData(true);
                        orderController.couponController.text = '';
                        if(orderController.isPartialPay || orderController.paymentMethodIndex == 1){
                          orderController.checkBalanceStatus(totalPrice, 0);
                        }
                      }
                    }
                  },
                  child: Container(
                    height: 45, width: (couponController.discount! <= 0 && !couponController.freeDelivery) ? 100 : 50,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: (couponController.discount! <= 0 && !couponController.freeDelivery) ? Theme.of(context).primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: (couponController.discount! <= 0 && !couponController.freeDelivery) ? !couponController.isLoading ? Text(
                      'apply'.tr,
                      style: robotoMedium.copyWith(color: Theme.of(context).cardColor),
                    ) : const SizedBox(
                      height: 30, width: 30,
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                        : Icon(Icons.clear, color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

          ]),
        );
      },
    ) : const SizedBox();
  }
}
