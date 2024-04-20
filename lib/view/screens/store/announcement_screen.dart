import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:citgroupvn_ecommerce_store/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce_store/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_store/util/styles.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_text_field.dart';

class AnnouncementScreen extends StatefulWidget {
  final int announcementStatus;
  final String announcementMessage;
  const AnnouncementScreen({Key? key, required this.announcementStatus, required this.announcementMessage}) : super(key: key);

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}
class _AnnouncementScreenState extends State<AnnouncementScreen> {

  final tooltipController = JustTheController();
  final TextEditingController _announcementController = TextEditingController();
  bool announcementStatus = false;

  @override
  void initState() {
    announcementStatus = widget.announcementStatus == 1 ? true : false;
    _announcementController.text = widget.announcementMessage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'announcement'.tr,
            menuWidget: Switch(
              value: announcementStatus,
              onChanged: (value) {
                setState(() {
                  announcementStatus = value;
                });
              },
            ),
          ),

          body: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(children: [

              Row(children: [
                Text("announcement_content".tr, style: robotoRegular),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                JustTheTooltip(
                  backgroundColor: Colors.black87,
                  controller: tooltipController,
                  preferredDirection: AxisDirection.down,
                  tailLength: 14,
                  tailBaseWidth: 20,
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('this_feature_is_for_sharing_important_information_or_announcements_related_to_the_store'.tr,style: robotoRegular.copyWith(color: Theme.of(context).cardColor)),
                  ),
                  child: InkWell(
                    onTap: () => tooltipController.showTooltip(),
                    child: const Icon(Icons.info_outline, size: 15),
                  ),
                  // child: const Icon(Icons.info_outline),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              CustomTextField(
                hintText: "type_announcement".tr,
                controller: _announcementController,
                maxLines: 5,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              !storeController.isLoading ? CustomButton(
                onPressed: () {
                  if(_announcementController.text.isEmpty) {
                    showCustomSnackBar('enter_announcement'.tr);
                  }else {
                    storeController.updateAnnouncement(announcementStatus ? 1 : 0, _announcementController.text);
                  }
                },
                buttonText: 'publish'.tr,
              ) : const Center(child: CircularProgressIndicator()),

            ]),
          ),
        );
      }
    );
  }
}
