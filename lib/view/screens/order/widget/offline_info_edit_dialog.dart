import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_text_field.dart';
class OfflineInfoEditDialog extends StatefulWidget {
  final OfflinePayment offlinePayment;
  final int orderId;
  const OfflineInfoEditDialog({Key? key, required this.offlinePayment, required this.orderId}) : super(key: key);

  @override
  State<OfflineInfoEditDialog> createState() => _OfflineInfoEditDialogState();
}

class _OfflineInfoEditDialogState extends State<OfflineInfoEditDialog> {

  @override
  void initState() {
    super.initState();

    Get.find<OrderController>().informationControllerList = [];
    Get.find<OrderController>().informationFocusList = [];
    for (int i=0; i<widget.offlinePayment.input!.length ; i++) {
      Get.find<OrderController>().informationControllerList.add(TextEditingController(text: widget.offlinePayment.input![i].userData));
      Get.find<OrderController>().informationFocusList.add(FocusNode());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: GetBuilder<OrderController>(
            builder: (orderController) {
              return SingleChildScrollView(
                child: Column(children: [

                  Image.asset(Images.offlinePayment, height: 100),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Text('update_payment_info'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodySmall?.color,
                  )),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  ListView.builder(
                    itemCount: orderController.informationControllerList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: CustomTextField(
                          titleText: widget.offlinePayment.input![i].userInput.toString().replaceAll('_', ' '),
                          controller: orderController.informationControllerList[i],
                          focusNode: orderController.informationFocusList[i],
                          nextFocus: i != orderController.informationControllerList.length-1 ? orderController.informationFocusList[i+1] : null,
                          inputAction: i != orderController.informationControllerList.length-1 ? TextInputAction.next : TextInputAction.done,
                        ),
                      );
                    },
                  ),

                  Row(children: [
                    const Spacer(),

                    CustomButton(
                      width: 100,
                      color: Theme.of(context).disabledColor.withOpacity(0.5),
                      textColor: Theme.of(context).textTheme.bodyMedium!.color,
                      buttonText: 'cancel'.tr,
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeLarge),

                    CustomButton(
                      width: 100,
                      buttonText: 'update'.tr,
                      isLoading: orderController.isLoading,
                      onPressed: () {

                        for(int i=0; i<orderController.informationControllerList.length; i++){
                          if(orderController.informationControllerList[i].text.isEmpty) {
                            showCustomSnackBar('please_provide_every_information'.tr);
                            break;
                          }else {
                            Map<String, String> data = {
                              "_method": "put",
                              "order_id": widget.orderId.toString(),
                              "method_id": widget.offlinePayment.data!.methodId.toString(),
                            };

                            for(int i=0; i<orderController.informationControllerList.length; i++){
                              data.addAll({
                                widget.offlinePayment.input![i].userInput.toString() : orderController.informationControllerList[i].text,
                              });
                            }

                            orderController.updateOfflineInfo(jsonEncode(data)).then((success) {
                              if(success) {
                                Get.back();
                              }
                            });
                          }
                        }


                      },
                    ),


                  ])
                ]),
              );
            }
          ),
        ),
      ),
    );
  }
}
