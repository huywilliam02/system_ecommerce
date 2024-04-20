import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/no_data_screen.dart';
import 'package:citgroupvn_ecommerce/view/base/item_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/base/web_item_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_store_widget.dart';

class WebItemsView extends StatefulWidget {
  final List<Item?>? items;
  final List<Store?>? stores;
  final bool isStore;
  final bool fromStore;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inStorePage;
  final bool isFeatured;
  const WebItemsView({Key? key, required this.stores, required this.items, required this.isStore, this.isScrollable = false,
    this.shimmerLength = 20, this.padding = const EdgeInsets.all(Dimensions.paddingSizeSmall), this.noDataText,
    this.isCampaign = false, this.inStorePage = false, this.isFeatured = false, this.fromStore = false}) : super(key: key);

  @override
  State<WebItemsView> createState() => _WebItemsViewState();
}

class _WebItemsViewState extends State<WebItemsView> {
  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if(widget.isStore) {
      isNull = widget.stores == null;
      if(!isNull) {
        length = widget.stores!.length;
      }
    }else {
      isNull = widget.items == null;
      if(!isNull) {
        length = widget.items!.length;
      }
    }

    return Column(children: [

      !isNull ? length > 0 ? GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
          childAspectRatio: ResponsiveHelper.isDesktop(context) ? widget.isStore ? 1.1 : 0.9 : 1,
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : (widget.fromStore || widget.isStore)  ? 4 : 5,
        ),
        physics: widget.isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: widget.isScrollable ? false : true,
        itemCount: length,
        padding: widget.padding,
        itemBuilder: (context, index) {
          return WebItemWidget(
            isStore: widget.isStore, item: widget.isStore ? null : widget.items![index], isFeatured: widget.isFeatured,
            store: widget.isStore ? widget.stores![index] : null, index: index, length: length, isCampaign: widget.isCampaign,
            inStore: widget.inStorePage,
          );

        },
      ) : NoDataScreen(
        text: widget.noDataText ?? (widget.isStore ? Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
            ? 'no_restaurant_available'.tr : 'no_store_available'.tr : 'no_item_available'.tr),
      ) : GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
          childAspectRatio: ResponsiveHelper.isDesktop(context) ?  widget.isStore ? 1.1 : 0.9 : 1,
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : (widget.fromStore || widget.isStore)  ? 4 : 5,
        ),
        physics: widget.isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: widget.isScrollable ? false : true,
        itemCount: widget.shimmerLength,
        padding: widget.padding,
        itemBuilder: (context, index) {
          return ResponsiveHelper.isDesktop(context) ? const WebStoreShimmer()
              : ItemShimmer(isEnabled: isNull, isStore: widget.isStore, hasDivider: index != widget.shimmerLength-1);
        },
      ),

    ]);
  }
}
