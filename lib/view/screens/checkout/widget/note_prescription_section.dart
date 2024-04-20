import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_text_field.dart';
import 'package:citgroupvn_ecommerce/view/base/image_picker_widget.dart';
class NoteAndPrescriptionSection extends StatelessWidget {
  final OrderController orderController;
  final int? storeId;
  const NoteAndPrescriptionSection({Key? key, required this.orderController, this.storeId, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('additional_note'.tr, style: robotoMedium),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      CustomTextField(
        controller: orderController.noteController,
        titleText: 'please_provide_extra_napkin'.tr,
        maxLines: 3,
        inputType: TextInputType.multiline,
        inputAction: TextInputAction.done,
        capitalization: TextCapitalization.sentences,
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      storeId == null && Get.find<SplashController>().configModel!.moduleConfig!.module!.orderAttachment! ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('prescription'.tr, style: robotoMedium),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              '(${'max_size_2_mb'.tr})',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ImagePickerWidget(
            image: '', rawFile: orderController.rawAttachment,
            onTap: () => orderController.pickImage(),
          ),
        ],
      ) : const SizedBox(),
    ]);
  }
}
