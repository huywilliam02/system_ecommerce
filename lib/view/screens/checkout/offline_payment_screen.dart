import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/body/place_order_body.dart';
import 'package:citgroupvn_ecommerce/data/model/response/offline_method_model.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_text_field.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';

class OfflinePaymentScreen extends StatefulWidget {
  final PlaceOrderBody placeOrderBody;
  final int zoneId;
  final double total;
  final double? maxCodOrderAmount;
  final bool fromCart;
  final bool isCashOnDeliveryActive;
  final bool forParcel;

  const OfflinePaymentScreen({
    Key? key, required this.placeOrderBody, required this.zoneId,
    required this.total, required this.maxCodOrderAmount, required this.fromCart, required this.isCashOnDeliveryActive, required this.forParcel,
  }) : super(key: key);

  @override
  State<OfflinePaymentScreen> createState() => _OfflinePaymentScreenState();
}

class _OfflinePaymentScreenState extends State<OfflinePaymentScreen> {
  PageController pageController = PageController(viewportFraction: 0.85, initialPage: Get.find<OrderController>().selectedOfflineBankIndex);
  final TextEditingController _customerNoteController = TextEditingController();
  final FocusNode _customerNoteNode = FocusNode();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
    if(Get.find<OrderController>().offlineMethodList == null){
      await Get.find<OrderController>().getOfflineMethodList();
    }
    Get.find<OrderController>().informationControllerList = [];
    Get.find<OrderController>().informationFocusList = [];
    if(Get.find<OrderController>().offlineMethodList != null && Get.find<OrderController>().offlineMethodList!.isNotEmpty) {
      for(int index=0; index<Get.find<OrderController>().offlineMethodList![Get.find<OrderController>().selectedOfflineBankIndex].methodInformations!.length; index++) {
        Get.find<OrderController>().informationControllerList.add(TextEditingController());
        Get.find<OrderController>().informationFocusList.add(FocusNode());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'offline_payment'.tr),
      body: SafeArea(
        child: GetBuilder<OrderController>(
          builder: (orderController) {
            List<MethodInformations>? methodInformation = orderController.offlineMethodList != null ? orderController.offlineMethodList![orderController.selectedOfflineBankIndex].methodInformations! : [];

            return orderController.offlineMethodList != null ? Column(children: [
              Expanded(child: SingleChildScrollView(
                child: FooterView(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Image.asset(Images.offlinePayment, height: 100),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Text('pay_your_bill_using_the_info'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodySmall?.color,
                      )),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      SizedBox(
                        height: 160,
                        child: PageView.builder(
                          onPageChanged: (int pageIndex) {
                            orderController.selectOfflineBank(pageIndex);
                            orderController.changesMethod();
                          },
                          scrollDirection: Axis.horizontal,
                            controller: pageController,
                            itemCount: orderController.offlineMethodList!.length,
                            itemBuilder: (context, index) {
                            bool selected = orderController.selectedOfflineBankIndex == index;
                          return bankCard(context, orderController.offlineMethodList, index, selected);
                        }),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Text(
                        '${'amount'.tr} '' ${PriceConverter.convertPrice(widget.total)}',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'payment_info'.tr,
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),

                          ListView.builder(
                            itemCount: orderController.informationControllerList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                child: CustomTextField(
                                  titleText: methodInformation[i].customerPlaceholder!,
                                  controller: orderController.informationControllerList[i],
                                  focusNode: orderController.informationFocusList[i],
                                  nextFocus: i != orderController.informationControllerList.length-1 ? orderController.informationFocusList[i+1] : _customerNoteNode,
                                ),
                              );
                            },
                          ),

                          CustomTextField(
                            titleText: 'write_your_note'.tr,
                            controller: _customerNoteController,
                            focusNode: _customerNoteNode,
                            inputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ]),
                      ),

                      ResponsiveHelper.isDesktop(context) ? completeButton(orderController, methodInformation) : const SizedBox(),



                    ]),
                  ),
                ),
              )),

              !ResponsiveHelper.isDesktop(context) ? completeButton(orderController, methodInformation) : const SizedBox(),


            ]) : const Center(child: CircularProgressIndicator());
          }
        ),
      ),
    );
  }

  Widget completeButton(OrderController orderController, List<MethodInformations>? methodInformation, ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
      child: CustomButton(
        buttonText: 'complete'.tr,
        isLoading: orderController.isLoading,
        onPressed: () async {
          bool complete = false;
          String text = '';
          for(int i=0; i<methodInformation!.length; i++){
            if(methodInformation[i].isRequired!) {
              if(orderController.informationControllerList[i].text.isEmpty){
                complete = false;
                text = methodInformation[i].customerPlaceholder!;
                break;
              } else {
                complete = true;
              }
            } else {
              complete = true;
            }
          }

          if(complete) {
            String methodId = orderController.offlineMethodList![orderController.selectedOfflineBankIndex].id.toString();

            String? orderId = await orderController.placeOrder(widget.placeOrderBody, widget.zoneId, widget.total, widget.maxCodOrderAmount, widget.fromCart, widget.isCashOnDeliveryActive, isOfflinePay: true, forParcel: widget.forParcel);

            if(orderId.isNotEmpty) {
              Map<String, String> data = {
                "_method": "put",
                "order_id": orderId,
                "method_id": methodId,
                "customer_note": _customerNoteController.text,
              };

              for(int i=0; i<methodInformation.length; i++){
                data.addAll({
                  methodInformation[i].customerInput! : orderController.informationControllerList[i].text,
                });
              }

              orderController.saveOfflineInfo(jsonEncode(data)).then((success) {
                if(success){
                  Get.offAllNamed(RouteHelper.getOrderDetailsRoute(int.parse(orderId), fromOffline: true, contactNumber: widget.placeOrderBody.contactPersonNumber));
                }
              });
            }


          } else {
            showCustomSnackBar(text);
          }
        },
      ),
    );
  }

  Widget bankCard(BuildContext context, List<OfflineMethodModel>? offlineMethodList, int index, bool selected) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? Theme.of(context).cardColor : Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: selected ? const [BoxShadow(color: Colors.black12, blurRadius: 10)] : [],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('bank_info'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
          const Spacer(),

          selected ? Row(children: [
            Text('pay_on_this_account'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),),
            Icon(Icons.check_circle_rounded, size: 20, color: Theme.of(context).primaryColor),
          ]) : const SizedBox(),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        ListView.builder(
          itemCount: offlineMethodList![index].methodFields!.length,
            addRepaintBoundaries: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
            child: Row(children: [
              Text(
                '${offlineMethodList[index].methodFields![i].inputName!.toString().replaceAll('_', ' ')} : ',
                style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5)),
              ),
              Text(offlineMethodList[index].methodFields![i].inputData!, style: robotoMedium),
            ]),
          );
        })


      ]),
    );
  }
}
