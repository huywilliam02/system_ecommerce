import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_text_field.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/tips_widget.dart';
class DeliveryManTipsSection extends StatefulWidget {
  final bool takeAway;
  final JustTheController tooltipController3;
  final double totalPrice;
  final Function(double x) onTotalChange;
  final int? storeId;
  const DeliveryManTipsSection({ Key? key, required this.takeAway, required this.tooltipController3, required this.totalPrice, required this.onTotalChange, this.storeId}) : super(key: key);

  @override
  State<DeliveryManTipsSection> createState() => _DeliveryManTipsSectionState();
}

class _DeliveryManTipsSectionState extends State<DeliveryManTipsSection> {
  bool canCheckSmall = false;

  @override
  Widget build(BuildContext context) {
    double total = widget.totalPrice;
    return GetBuilder<OrderController>(
      builder: (orderController) {
        return Column(
          children: [
            (!widget.takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
              ),
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeLarge),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(children: [
                  Text('delivery_man_tips'.tr, style: robotoMedium),

                  JustTheTooltip(
                    backgroundColor: Colors.black87,
                    controller: widget.tooltipController3,
                    preferredDirection: AxisDirection.right,
                    tailLength: 14,
                    tailBaseWidth: 20,
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'.tr,style: robotoRegular.copyWith(color: Colors.white)),
                    ),
                    child: InkWell(
                      onTap: () => widget.tooltipController3.showTooltip(),
                      child: const Icon(Icons.info_outline),
                    ),
                  ),

                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                SizedBox(
                  height: (orderController.selectedTips == AppConstants.tips.length-1) && orderController.canShowTipsField
                      ? 0 : ResponsiveHelper.isDesktop(context) ? 80 : 60,
                  child: (orderController.selectedTips == AppConstants.tips.length-1) && orderController.canShowTipsField
                  ? const SizedBox() : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: AppConstants.tips.length,
                    itemBuilder: (context, index) {
                      return TipsWidget(
                        title: AppConstants.tips[index] == '0' ? 'not_now'.tr : (index != AppConstants.tips.length -1) ? PriceConverter.convertPrice(double.parse(AppConstants.tips[index].toString()), forDM: true) : AppConstants.tips[index].tr,
                        isSelected: orderController.selectedTips == index,
                        isSuggested: index != 0 && AppConstants.tips[index] == orderController.mostDmTipAmount.toString(),
                        onTap: () async {
                          total = total - orderController.tips;
                          orderController.updateTips(index);
                          if(orderController.selectedTips != AppConstants.tips.length-1) {
                            orderController.addTips(double.parse(AppConstants.tips[index]));
                          }
                          if(orderController.selectedTips == AppConstants.tips.length-1) {
                            orderController.showTipsField();
                          }
                          orderController.tipController.text = orderController.tips.toString();

                          if(orderController.isPartialPay || orderController.paymentMethodIndex == 1) {

                            orderController.checkBalanceStatus((total + orderController.tips), 0);
                          }

                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: (orderController.selectedTips == AppConstants.tips.length-1) && orderController.canShowTipsField ? Dimensions.paddingSizeExtraSmall : 0),

                orderController.selectedTips == AppConstants.tips.length-1 ? const SizedBox() : ListTile(
                  onTap: () => orderController.toggleDmTipSave(),
                  leading: Checkbox(
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    activeColor: Theme.of(context).primaryColor,
                    value: orderController.isDmTipSave,
                    onChanged: (bool? isChecked) => orderController.toggleDmTipSave(),
                  ),
                  title: Text('save_for_later'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                  dense: true,
                  horizontalTitleGap: 0,
                ),
                SizedBox(height: orderController.selectedTips == AppConstants.tips.length-1 ? Dimensions.paddingSizeDefault : 0),

                orderController.selectedTips == AppConstants.tips.length-1 ? Row(children: [
                  Expanded(
                    child: CustomTextField(
                      titleText: 'enter_amount'.tr,
                      controller: orderController.tipController,
                      inputAction: TextInputAction.done,
                      inputType: TextInputType.number,
                      onChanged: (String value) async {
                        if(value.isNotEmpty) {
                          try {
                            if(double.parse(value) >= 0){
                              if(Get.find<AuthController>().isLoggedIn()) {
                                total = total - orderController.tips;
                                await orderController.addTips(double.parse(value));
                                total = total + orderController.tips;
                                widget.onTotalChange(total);
                                if(Get.find<UserController>().userInfoModel!.walletBalance! < total && orderController.paymentMethodIndex == 1){
                                  orderController.checkBalanceStatus(total, 0);
                                  canCheckSmall = true;
                                } else if(Get.find<UserController>().userInfoModel!.walletBalance! > total && canCheckSmall && orderController.isPartialPay){
                                  orderController.checkBalanceStatus(total, 0);
                                }
                              } else {
                                orderController.addTips(double.parse(value));
                              }

                            }else{
                              showCustomSnackBar('tips_can_not_be_negative'.tr);
                            }
                          }catch(e) {
                            showCustomSnackBar('invalid_input'.tr);
                            orderController.addTips(0.0);
                            orderController.tipController.text = orderController.tipController.text.substring(0, orderController.tipController.text.length-1);
                            orderController.tipController.selection = TextSelection.collapsed(offset: orderController.tipController.text.length);
                          }
                        }else {
                          orderController.addTips(0.0);
                        }
                      },

                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  InkWell(
                    onTap: () {
                      orderController.updateTips(0);
                      orderController.showTipsField();
                      if(orderController.isPartialPay) {
                        orderController.changePartialPayment();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: const Icon(Icons.clear),
                    ),
                  ),

                ]) : const SizedBox(),

              ]),
            ) : const SizedBox.shrink(),

            SizedBox(height: (!widget.takeAway && widget.storeId == null && Get.find<SplashController>().configModel!.dmTipsStatus == 1)
                ? Dimensions.paddingSizeSmall : 0),
          ],
        );
      }
    );
  }
}
