import 'package:citgroupvn_ecommerce/controller/search_controller.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/base/item_view.dart';
import 'package:citgroupvn_ecommerce/view/base/web_item_view.dart';

class ItemView extends StatelessWidget {
  final bool isItem;
  const ItemView({Key? key, required this.isItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SearchingController>(builder: (searchController) {
        return SingleChildScrollView(
          child: FooterView(
            child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: ResponsiveHelper.isDesktop(context) ? WebItemsView(
                  isStore: isItem, items: searchController.searchItemList, stores: searchController.searchStoreList,
                ) : ItemsView(
                  isStore: isItem, items: searchController.searchItemList, stores: searchController.searchStoreList,
                ),
            ),
          ),
        );
      }),
    );
  }
}
