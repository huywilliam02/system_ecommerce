import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/config_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce_store/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce_store/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_store/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_store/util/styles.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_image.dart';

class PendingItemDetailsScreen extends StatefulWidget {
  final int id;
  const PendingItemDetailsScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<PendingItemDetailsScreen> createState() => _PendingItemDetailsScreenState();
}

class _PendingItemDetailsScreenState extends State<PendingItemDetailsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    Get.find<StoreController>().getPendingItemDetails(widget.id, canUpdate: false);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        return Scaffold(
          appBar: AppBar(
              title: Column(children: [
                Text('item_details'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(storeController.pendingItem![0].isRejected == 0 ? 'this_item_is_under_review'.tr : 'this_item_has_been_rejected'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: storeController.pendingItem![0].isRejected  == 0 ? Colors.blue : Theme.of(context).colorScheme.error)),
              ]),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: Theme.of(context).textTheme.bodyLarge!.color,
                onPressed: () => Get.back(),
              ),
              backgroundColor: Theme.of(context).cardColor,
              elevation: 0.4,
            actions: [
              storeController.item != null ? IconButton(
                onPressed: () => Get.find<StoreController>().deleteItem(storeController.item!.id, pendingItem: true),
                icon: Icon(CupertinoIcons.delete_simple, color: Theme.of(context).colorScheme.error),
              ) : const SizedBox(),
            ],
          ),

          body: storeController.item != null
              ? EnglishLanguageItemTab(item: storeController.item!,storeController: storeController)
              : const Center(child: CircularProgressIndicator()),
        );
      }
    );
  }
}

class EnglishLanguageItemTab extends StatelessWidget {
  final Item item;
  final StoreController storeController;
  const EnglishLanguageItemTab({Key? key, required this.item, required this.storeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Language>? languageList = Get.find<SplashController>().configModel!.language;
    String itemName = '';
    String itemDescription = '';
    for(Translation translation in item.translations!){
      if(translation.locale == languageList![storeController.languageSelectedIndex].key){
        if(translation.key == 'name') {
          itemName = translation.value!;
        }
        if(translation.key == 'description') {
          itemDescription = translation.value!;
        }
      }
    }
    Module? module = Get.find<SplashController>().configModel!.moduleConfig!.module;

    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),

        SizedBox(
          height: 40,
          child: ListView.builder(
            itemCount: languageList!.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              bool selected = index == storeController.languageSelectedIndex;
              return Padding(
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: InkWell(
                  onTap: () => storeController.setLanguageSelect(index),
                  child: Column(children: [
                    Text(
                      languageList[index].value!,
                      style: selected ? robotoBold.copyWith(color: Theme.of(context).primaryColor) : robotoMedium,
                    ),
                    Container(
                      height: 2, width: 100,
                      color: selected ? Theme.of(context).primaryColor : Colors.transparent,
                      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                    ),

                  ]),
                ),
              );
            },
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                color: Theme.of(context).cardColor,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    height: 90, width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Row(children: [
                        Container(
                          height: 70, width: 70,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Theme.of(context).disabledColor.withOpacity(0.2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${item.image}',
                              fit: BoxFit.cover, width: 70, height: 70,
                            ),
                          ),
                        ),

                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(itemName, maxLines: 2, overflow: TextOverflow.ellipsis, style: robotoMedium),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Text(storeController.pendingItem![0].isRejected == 0 ? 'this_item_is_under_review'.tr : 'this_item_has_been_rejected'.tr,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: storeController.pendingItem![0].isRejected  == 0 ? Colors.blue : Theme.of(context).colorScheme.error)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),

                  Text(
                    itemDescription,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Column(children: [
                TitleTagWidget(title: 'general_information'.tr),

                InformationTextWidget(
                  title: 'store'.tr,
                  value: item.storeName.toString(),
                ),

                InformationTextWidget(
                  title: 'category'.tr,
                  value: item.categoryIds![0].name.toString(),
                ),

                item.categoryIds!.length > 1 ? InformationTextWidget(
                  title: 'sub_category'.tr,
                  value: item.categoryIds![1].name.toString(),
                ) : const SizedBox(),

                InformationTextWidget(
                  title: 'total_stock'.tr,
                  value: item.stock.toString(),
                ),

                item.unitType != null ? InformationTextWidget(
                  title: 'product_unit'.tr,
                  value: item.unitType!,
                ) : const SizedBox(),

                InformationTextWidget(
                  title: 'is_organic'.tr,
                  value: item.veg == 1 ? 'yes'.tr : 'no'.tr,
                ),

              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Column(children: [
                TitleTagWidget(title: 'price_information'.tr),

                InformationTextWidget(
                  title: 'unit_price'.tr,
                  value: PriceConverter.convertPrice(item.price!),
                ),

                InformationTextWidget(
                  title: 'tax'.tr,
                  value: item.tax.toString(),
                ),

                InformationTextWidget(
                  title: 'discount'.tr,
                  value: item.discount.toString(),
                ),

              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),


              (item.foodVariations != null && item.foodVariations!.isNotEmpty) || (item.variations != null && item.variations!.isNotEmpty) ? Column(children: [
                TitleTagWidget(title: 'available_variation'.tr),

                Get.find<SplashController>().getStoreModuleConfig().newVariation! ? VariationViewForFood(item: item)
                    : VariationViewForGeneral(item: item, stock: module!.stock),
              ]) : const SizedBox(),
              SizedBox(height: (item.foodVariations != null && item.foodVariations!.isNotEmpty) || (item.variations != null && item.variations!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),


              (item.addOns!.isNotEmpty && module!.addOn!) ? Column(children: [
                TitleTagWidget(title: 'addons'.tr),

                (item.addOns!.isNotEmpty && module.addOn!) ? ListView.builder(
                  itemCount: item.addOns!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InformationTextWidget(
                      title: item.addOns![index].name!,
                      value: PriceConverter.convertPrice(item.addOns![index].price),
                    );
                  },
                ) : const SizedBox(),
              ]) : const SizedBox(),
              SizedBox(height: (item.addOns!.isNotEmpty && module!.addOn!) ? Dimensions.paddingSizeSmall : 0),

              (item.tags != null && item.tags!.isNotEmpty) ? Column(children: [
                TitleTagWidget(title: 'tags'.tr),

                (item.tags != null && item.tags!.isNotEmpty) ? Container(
                  height: 35,
                  width: context.width,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  color: Theme.of(context).cardColor,
                  child: ListView.builder(
                    itemCount: item.tags!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Wrap(
                        children: [
                          Text(item.tags![index].tag!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        ],
                      );
                    },
                  ),
                ) : const SizedBox(),
              ]) : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeSmall),

            ]),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: CustomButton(
              onPressed: () => Get.toNamed(RouteHelper.getItemRoute(item)),
              buttonText: 'edit_and_resubmit'.tr,
            ),
          ),
        ),
      ],
    );
  }
}

class VariationViewForFood extends StatelessWidget {
  final Item item;
  const VariationViewForFood({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (item.foodVariations != null && item.foodVariations!.isNotEmpty) ? ListView.builder(
      itemCount: item.foodVariations!.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('${item.foodVariations![index].name!} - ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
              Text(
                ' ${item.foodVariations![index].type == 'multi' ? 'multiple_select'.tr : 'single_select'.tr}'
                    ' (${item.foodVariations![index].required == 'on' ? 'required'.tr : 'optional'.tr})',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
            ]),

            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            ListView.builder(
              itemCount: item.foodVariations![index].variationValues!.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i){
                return InformationTextWidget(
                  title: '${item.foodVariations![index].variationValues![i].level}',
                  value: PriceConverter.convertPrice(double.parse(item.foodVariations![index].variationValues![i].optionPrice!)),
                );
              },
            ),

          ]),
        );
      },
    ) : const SizedBox();
  }
}

class VariationViewForGeneral extends StatelessWidget {
  final Item item;
  final bool? stock;
  const VariationViewForGeneral({Key? key, required this.item, required this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (item.variations != null && item.variations!.isNotEmpty) ? ListView.builder(
      itemCount: item.variations!.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
          color: Theme.of(context).cardColor,
          child: Column(children: [
            Row(children: [
              Expanded(
                flex: 3,
                child: Text(item.variations![index].type!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
              ),

              Expanded(
                flex: 7,
                child: Row(
                  children: [
                    Text(':', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Text(
                      PriceConverter.convertPrice(item.variations![index].price),
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ),
                    SizedBox(width: stock! ? Dimensions.paddingSizeExtraSmall : 0),
                    stock! ? Text(
                      '(${item.variations![index].stock})',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                    ) : const SizedBox(),
                  ],
                ),
              ),

            ]),
          ]),
        );
      },
    ) : const SizedBox();
  }
}


class InformationTextWidget extends StatelessWidget {
  final String title;
  final String value;
  const InformationTextWidget({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
      color: Theme.of(context).cardColor,
      child: Column(children: [
        Row(children: [
          Expanded(
            flex: 3,
            child: Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
          ),

          Expanded(
            flex: 7,
            child: Row(
              children: [
                Text(':', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text(value, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
              ],
            ),
          ),

        ]),
      ]),
    );
  }
}

class TitleTagWidget extends StatelessWidget {
  final String title;
  const TitleTagWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35, width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),

      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border.symmetric(horizontal: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.1))),
      ),
      child: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
    );
  }
}


