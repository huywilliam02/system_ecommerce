import 'package:citgroupvn_ecommerce/controller/banner_controller.dart';
import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/basic_campaign_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WebBannerView extends StatelessWidget {
  final BannerController bannerController;
  const WebBannerView({Key? key, required this.bannerController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return Container(
      // color: const Color(0xFF171A29),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(width: 1210, height: 220, child: bannerController.bannerImageList != null ? Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: PageView.builder(
                  controller: pageController,
                  itemCount: (bannerController.bannerImageList!.length/2).ceil(),
                  itemBuilder: (context, index) {
                    int index1 = index * 2;
                    int index2 = (index * 2) + 1;
                    bool hasSecond = index2 < bannerController.bannerImageList!.length;

                    String? baseUrl1 = bannerController.bannerDataList![index1] is BasicCampaignModel ? Get.find<SplashController>()
                        .configModel!.baseUrls!.campaignImageUrl : Get.find<SplashController>().configModel!.baseUrls!.bannerImageUrl;
                    String? baseUrl2 = hasSecond ? bannerController.bannerDataList![index2] is BasicCampaignModel ? Get.find<SplashController>()
                        .configModel!.baseUrls!.campaignImageUrl : Get.find<SplashController>().configModel!.baseUrls!.bannerImageUrl : '';

                    return Row(children: [

                      Expanded(child: InkWell(
                        onTap: () => _onTap(index1, context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: '$baseUrl1/${bannerController.bannerImageList![index1]}', fit: BoxFit.cover, height: 220,
                          ),
                        ),
                      )),

                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(child: hasSecond ? InkWell(
                        onTap: () => _onTap(index2, context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: '$baseUrl2/${bannerController.bannerImageList![index2]}', fit: BoxFit.cover, height: 220,
                          ),
                        ),
                      ) : const SizedBox()),

                    ]);
                  },
                  onPageChanged: (int index) => bannerController.setCurrentIndex(index, true),
                ),
              ),

              bannerController.currentIndex != 0 ? Positioned(
                top: 0, bottom: 0, left: 0,
                child: InkWell(
                  onTap: () => pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  child: Container(
                    height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Theme.of(context).cardColor,
                    ),
                    padding: const EdgeInsets.only(left: 10),
                    child: const Icon(Icons.arrow_back_ios),
                  ),
                ),
              ) : const SizedBox(),

              bannerController.currentIndex != ((bannerController.bannerImageList!.length/2).ceil()-1) ? Positioned(
                top: 0, bottom: 0, right: 0,
                child: InkWell(
                  onTap: () => pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  child: Container(
                    height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Theme.of(context).cardColor,
                    ),
                    child: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ) : const SizedBox(),

            ],
          ) : WebBannerShimmer(bannerController: bannerController)),

          const SizedBox(height: Dimensions.paddingSizeLarge),
          bannerController.bannerImageList != null ? Builder(
              builder: (context) {
                List<String> finalBanner = [];
                for(int i=0; i<bannerController.bannerImageList!.length; i++){
                  if(i%2==0){
                    finalBanner.add(bannerController.bannerImageList![i]!);
                  }
                }
                int totalBanner = bannerController.bannerImageList!.length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: finalBanner.map((bnr) {
                    int index = finalBanner.indexOf(bnr);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: index == bannerController.currentIndex ? Container(
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                        child: Text('${(index*2) + 2}/$totalBanner', style: robotoRegular.copyWith(color: Colors.white, fontSize: 8)),
                      ) : Container(
                        height: 4.18, width: 5.57,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.5), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                      ),
                    );
                  }).toList(),
                );
              }
          ) : const SizedBox(),
        ],
      ),
    );
  }

  void _onTap(int index, BuildContext context) async {
    if(bannerController.bannerDataList![index] is Item) {
      Item? item = bannerController.bannerDataList![index];
      Get.find<ItemController>().navigateToItemPage(item, context);
    }else if(bannerController.bannerDataList![index] is Store) {
      Store store = bannerController.bannerDataList![index];
      Get.toNamed(
        RouteHelper.getStoreRoute(id: store.id, page: 'banner'),
        arguments: StoreScreen(store: store, fromModule: false),
      );
    }else if(bannerController.bannerDataList![index] is BasicCampaignModel) {
      BasicCampaignModel campaign = bannerController.bannerDataList![index];
      Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
    }else {
      String url = bannerController.bannerDataList![index];
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      }else {
        showCustomSnackBar('unable_to_found_url'.tr);
      }
    }
  }
}

class WebBannerShimmer extends StatelessWidget {
  final BannerController bannerController;
  const WebBannerShimmer({Key? key, required this.bannerController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: bannerController.bannerImageList == null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Row(children: [

          Expanded(child: Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[300]),
          )),

          const SizedBox(width: Dimensions.paddingSizeLarge),

          Expanded(child: Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[300]),
          )),

        ]),
      ),
    );
  }
}

