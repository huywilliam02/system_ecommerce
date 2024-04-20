import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/view/base/web_page_title_widget.dart';

class PopularItemScreen extends StatefulWidget {
  final bool isPopular;
  final bool isSpecial;
  const PopularItemScreen({Key? key, required this.isPopular, required this.isSpecial}) : super(key: key);

  @override
  State<PopularItemScreen> createState() => _PopularItemScreenState();
}

class _PopularItemScreenState extends State<PopularItemScreen> {

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    if(widget.isPopular) {
      Get.find<ItemController>().getPopularItemList(true, Get.find<ItemController>().popularType, false);
    }else if(widget.isSpecial){
      Get.find<ItemController>().getDiscountedItemList(true, false);
    } else {
      Get.find<ItemController>().getReviewedItemList(true, Get.find<ItemController>().reviewType, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return GetBuilder<ItemController>(
      builder: (itemController) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: CustomAppBar(
            key: scaffoldKey,
            title: widget.isPopular ? isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr : widget.isSpecial ? 'special_offer'.tr : 'best_reviewed_item'.tr,
            showCart: true,
            type: widget.isPopular ? itemController.popularType : itemController.reviewType,
            onVegFilterTap: (String type) {
              if(widget.isPopular) {
                itemController.getPopularItemList(true, type, true);
              }else {
                itemController.getReviewedItemList(true, type, true);
              }
            },
          ),
          endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          body: Scrollbar(child: SingleChildScrollView(child: FooterView(child: Column(
            children: [
              WebScreenTitleWidget(
                title: widget.isPopular ? isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr : widget.isSpecial ? 'special_offer'.tr : 'best_reviewed_item'.tr,
              ),

              SizedBox(
                width: Dimensions.webMaxWidth,
                child: ItemsView(
                  isStore: false, stores: null,
                  items: widget.isPopular ? itemController.popularItemList
                      : widget.isSpecial ? itemController.discountedItemList
                      : itemController.reviewedItemList,
                ),
              ),
            ],
          )))),
        );
      }
    );
  }
}
