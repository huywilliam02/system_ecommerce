import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_delivery/util/styles.dart';

class CameraButtonSheet extends StatelessWidget {
  const CameraButtonSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 4, width: 50,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).disabledColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          InkWell(
            onTap: (){
              if(Get.isBottomSheetOpen!){
                Get.back();
              }
              Get.find<OrderController>().pickPrescriptionImage(isRemove: false, isCamera: true);
            },
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor.withOpacity(0.2)),
                child: Icon(Icons.camera_alt_outlined, size: 45, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text('from_camera'.tr, style: robotoMedium)
            ]),
          ),

          InkWell(
            onTap: () {
              if(Get.isBottomSheetOpen!){
                Get.back();
              }
              Get.find<OrderController>().pickPrescriptionImage(isRemove: false, isCamera: false);
            },
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor.withOpacity(0.2)),
                child: Icon(Icons.photo_library_outlined, size: 45, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text('from_gallery'.tr, style: robotoMedium),
            ]),
          )
        ]),
      ]),
    );
  }
}
