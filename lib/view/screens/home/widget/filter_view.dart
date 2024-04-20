import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';

class FilterView extends StatelessWidget {
  final StoreController storeController;
  const FilterView({Key? key, required this.storeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return storeController.storeModel != null ? PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem(value: 'all', textStyle: robotoMedium.copyWith(
            color: storeController.storeType == 'all'
                ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
          ), child: Text('all'.tr)),
          PopupMenuItem(value: 'take_away', textStyle: robotoMedium.copyWith(
            color: storeController.storeType == 'take_away'
                ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
          ), child: Text('take_away'.tr)),
          PopupMenuItem(value: 'delivery', textStyle: robotoMedium.copyWith(
            color: storeController.storeType == 'delivery'
                ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
          ), child: Text('delivery'.tr)),
        ];
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        child: Container(
          height: 40, width: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).primaryColor),
          ),
          child: Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
        ),
      ),
      onSelected: (dynamic value) => storeController.setStoreType(value),
    ) : const SizedBox();
  }
}
