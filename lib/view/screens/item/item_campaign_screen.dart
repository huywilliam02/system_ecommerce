import 'package:citgroupvn_ecommerce/controller/campaign_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';

class ItemCampaignScreen extends StatefulWidget {
  final bool isJustForYou;
  const ItemCampaignScreen({Key? key, required this.isJustForYou}) : super(key: key);

  @override
  State<ItemCampaignScreen> createState() => _ItemCampaignScreenState();
}

class _ItemCampaignScreenState extends State<ItemCampaignScreen> {

  @override
  void initState() {
    super.initState();

    Get.find<CampaignController>().getItemCampaignList(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.isJustForYou ? 'just_for_you'.tr : 'campaigns'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: Scrollbar(child: SingleChildScrollView(child: FooterView(child: SizedBox(
        width: Dimensions.webMaxWidth,
        child: GetBuilder<CampaignController>(builder: (campController) {
          return ItemsView(
            isStore: false, items: campController.itemCampaignList, stores: null,
            isCampaign: true, noDataText: 'no_campaign_found'.tr,
          );
        }),
      )))),
    );
  }
}
