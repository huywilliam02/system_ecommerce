import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce_store/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_store/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_store/util/images.dart';
import 'package:citgroupvn_ecommerce_store/util/styles.dart';
import 'package:citgroupvn_ecommerce_store/view/base/confirmation_dialog.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_image.dart';

class BannerListScreen extends StatefulWidget {
  const BannerListScreen({Key? key}) : super(key: key);

  @override
  State<BannerListScreen> createState() => _BannerListScreenState();
}

class _BannerListScreenState extends State<BannerListScreen> {
  final tooltipController = JustTheController();
  @override
  void initState() {
    Get.find<StoreController>().getBannerList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'banner_list'.tr,
        menuWidget: Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          child: JustTheTooltip(
            backgroundColor: Colors.black87,
            controller: tooltipController,
            preferredDirection: AxisDirection.down,
            tailLength: 14,
            tailBaseWidth: 20,
            content: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Image.asset(Images.noteIcon, height: 21, width: 21),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text('note'.tr, style: robotoBold.copyWith(color: Colors.white)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text('customer_will_see_these_banners_in_your_store_details_page_in_website_and_user_apps'.tr,
                  style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                ),
              ]),
            ),
            child: InkWell(
              onTap: () => tooltipController.showTooltip(),
              child: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
            ),
            // child: const Icon(Icons.info_outline),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: GetBuilder<StoreController>(builder: (storeController) {

                  return storeController.storeBannerList != null ? storeController.storeBannerList!.isNotEmpty ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: storeController.storeBannerList!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 180, width: Get.width,
                        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          color: Theme.of(context).cardColor,
                          boxShadow: [BoxShadow(color: Theme.of(context).disabledColor.withOpacity(0.1), blurRadius: 5, spreadRadius: 2, offset: const Offset(0, 0))],
                        ),
                        child: Column(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                              child: CustomImage(
                                image: '${Get.find<SplashController>().configModel!.baseUrls!.bannerImageUrl}/${storeController.storeBannerList![index].image}',
                                fit: BoxFit.cover, width: Get.width,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                Wrap(crossAxisAlignment: WrapCrossAlignment.center, runAlignment: WrapAlignment.center, children: [
                                  Text('${'redirection_url'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: storeController.storeBannerList![index].defaultLink != null ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor)),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),

                                  Text(storeController.storeBannerList![index].defaultLink == null ? 'N/A' : storeController.storeBannerList![index].defaultLink.toString(), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                                      color: storeController.storeBannerList![index].defaultLink != null ? Colors.blue : Theme.of(context).disabledColor)),
                                ]),
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                Wrap(crossAxisAlignment: WrapCrossAlignment.center, runAlignment: WrapAlignment.center, children: [
                                  Text('${'title'.tr}: ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),

                                  Text(storeController.storeBannerList![index].title.toString(), style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                ]),
                              ],
                            )),

                            InkWell(
                              onTap: (){
                                Get.toNamed(RouteHelper.getAddBannerRoute(storeBannerListModel: storeController.storeBannerList![index], isUpdate: true));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: Colors.blue, size: 15,),
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            InkWell(
                              onTap: (){
                                Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_delete_this_banner'.tr,
                                  onYesPressed: () {
                                  if(storeController.storeBannerList![index].id != null) {
                                    storeController.deleteBanner(storeController.storeBannerList![index].id);
                                  }
                                }), useSafeArea: false);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).colorScheme.error),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 15),
                              ),
                            ),

                          ]),
                        ]),
                      );
                    },
                  ) : Center(child: Text('no_banner_found'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))) : const Center(child: CircularProgressIndicator());
                }
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: GetBuilder<StoreController>(builder: (storeController) {
                  return CustomButton(
                    onPressed: () => Get.toNamed(RouteHelper.getAddBannerRoute(storeBannerListModel: null, isUpdate: false)),
                    buttonText: 'add_new_banner'.tr,
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}
