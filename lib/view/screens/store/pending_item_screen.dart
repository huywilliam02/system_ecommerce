import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce_store/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce_store/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_store/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_store/util/styles.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_image.dart';

class PendingItemScreen extends StatefulWidget {
  const PendingItemScreen({Key? key}) : super(key: key);

  @override
  State<PendingItemScreen> createState() => _PendingItemScreenState();
}

class _PendingItemScreenState extends State<PendingItemScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    Get.find<StoreController>().getPendingItemList(
      Get.find<StoreController>().offset.toString(), Get.find<StoreController>().type, canNotify: false,
    );
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(title: 'pending_for_approval'.tr),
      body: RefreshIndicator(
        onRefresh: () async {
          await Get.find<StoreController>().getPendingItemList(
            Get.find<StoreController>().offset.toString(), Get.find<StoreController>().type, canNotify: false,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: GetBuilder<StoreController>(builder: (storeController) {
              return Column(children: [

                Row(children: [
                  Expanded(
                    child: Text('new_product'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    /*TabBar(
                      controller: _tabController,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 3,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Theme.of(context).disabledColor,
                      unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                      labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      tabs: [
                        Tab(text: 'new_product'.tr),
                        Tab(text: 'update_request'.tr),
                      ],
                    ),*/
                  ),
                  const SizedBox(width: 40),

                  PopupMenuButton(

                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        getMenuItem(Get.find<StoreController>().statusList[0], context),
                        const PopupMenuDivider(),
                        getMenuItem(Get.find<StoreController>().statusList[1], context),
                        const PopupMenuDivider(),
                        getMenuItem(Get.find<StoreController>().statusList[2], context),
                      ];
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.2)),
                      ),
                      child: Icon(Icons.filter_list_sharp, color: Theme.of(context).textTheme.bodyLarge!.color, size: 20),
                    ),

                    onSelected: (dynamic value) {
                      int index = Get.find<StoreController>().statusList.indexOf(value);
                      Get.find<StoreController>().getPendingItemList(
                        Get.find<StoreController>().offset.toString(), Get.find<StoreController>().statusList[index],
                      );
                    },
                  ),
                ]),

                /*Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      NewProductItemTab(),
                      UpdateRequestItemTab(),
                    ],
                  ),
                ),*/

                Expanded(
                  child: storeController.pendingItem != null ? storeController.pendingItem!.isNotEmpty
                  ? ListView.builder(
                    itemCount: storeController.pendingItem!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        Get.toNamed(RouteHelper.getPendingItemDetailsRoute(storeController.pendingItem![index].id!));
                      },
                      child: Container(
                        height: 90, width: double.infinity,
                        margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          color: Theme.of(context).cardColor,
                          boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withOpacity(0.1), spreadRadius: 1, blurRadius: 1, offset: const Offset(0, 0))],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                                  image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${storeController.pendingItem![index].image}',
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
                                  Text(storeController.pendingItem![index].name.toString(), style: robotoMedium),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Row(children: [
                                    Text('${'category'.tr} : ', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                                    Text(storeController.pendingItem![index].categoryIds![index].name.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                  ]),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Text(PriceConverter.convertPrice(storeController.pendingItem![index].price), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                ],
                              ),
                            ),


                            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  color: storeController.pendingItem![index].isRejected  == 0 ? Colors.blue.withOpacity(0.1) : Theme.of(context).colorScheme.error.withOpacity(0.1),
                                ),
                                child: Text(
                                  storeController.pendingItem![index].isRejected  == 0 ? 'pending'.tr : 'rejected'.tr,
                                  style: robotoMedium.copyWith(
                                    color: storeController.pendingItem![index].isRejected  == 0 ? Colors.blue : Theme.of(context).colorScheme.error,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ),

                              InkWell(
                                onTap: () {
                                  storeController.getPendingItemDetails(storeController.pendingItem![index].id!).then((success) {
                                    if(success){
                                      Get.toNamed(RouteHelper.getItemRoute(storeController.item));
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    border: Border.all(color: Theme.of(context).primaryColor),
                                  ),
                                  child: storeController.isLoading
                                      ?  const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                                      : Icon(Icons.refresh, color: Theme.of(context).primaryColor, size: 20),
                                ),
                              ),
                            ]),

                          ]),
                        ),
                      ),
                    ),
                  ) : Center(child: Text('no_item_available'.tr)) :  const Center(child: CircularProgressIndicator()),

                ),
              ]);
            }
          ),
        ),
      ),
    );
  }

  PopupMenuItem getMenuItem(String status, BuildContext context) {
    return PopupMenuItem(
      value: status,
      height: 30,
      child: Text(status.toLowerCase().tr, style: robotoRegular.copyWith(
        color: status == 'pending' ? Theme.of(context).primaryColor : status == 'rejected' ? Theme.of(context).colorScheme.error : null,
      )),
    );
  }
}

/*class NewProductItemTab extends StatelessWidget {
  const NewProductItemTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => InkWell(
        onTap: () => Get.toNamed(RouteHelper.getPendingItemDetailsRoute()),
        child: Container(
        height: 90, width: double.infinity,
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withOpacity(0.1), spreadRadius: 1, blurRadius: 1, offset: const Offset(0, 0))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                child: const CustomImage(
                  image: '',
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
                  const Text('Chips', style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Row(children: [
                    Text('${'category'.tr} : ', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                    Text('Food Fair', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text('\$5.55', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                ],
              ),
            ),


            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Text('Pending', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
              ),

              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Icon(Icons.refresh, color: Theme.of(context).primaryColor, size: 20),
              ),
            ]),

          ]),
        ),
      ),
      ),
    );
  }
}*/

/*
class UpdateRequestItemTab extends StatelessWidget {
  const UpdateRequestItemTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => InkWell(
        onTap: () => Get.toNamed(RouteHelper.getPendingItemDetailsRoute()),
        child: Container(
          height: 90, width: double.infinity,
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withOpacity(0.1), spreadRadius: 1, blurRadius: 1, offset: const Offset(0, 0))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                  child: const CustomImage(
                    image: '',
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
                    const Text('Chips', style: robotoMedium),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Row(children: [
                      Text('${'category'.tr} : ', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                      Text('Food Fair', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text('\$5.55', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                  ],
                ),
              ),


              Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Text('Pending', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                ),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Icon(Icons.refresh, color: Theme.of(context).primaryColor, size: 20),
                ),
              ]),

            ]),
          ),
        ),
      ),
    );
  }
}*/
