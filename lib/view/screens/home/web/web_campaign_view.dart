import 'package:citgroupvn_ecommerce/controller/campaign_controller.dart';
import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/discount_tag.dart';
import 'package:citgroupvn_ecommerce/view/base/hover/on_hover.dart';
import 'package:citgroupvn_ecommerce/view/base/not_available_widget.dart';
import 'package:citgroupvn_ecommerce/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:citgroupvn_ecommerce/view/base/title_widget.dart';

class WebCampaignView extends StatelessWidget {
  final CampaignController campaignController;
  const WebCampaignView({Key? key, required this.campaignController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          // child: Text('campaigns'.tr, style: robotoMedium.copyWith(fontSize: 24)),
          child: TitleWidget(title: 'special_offers'.tr),
        ),

        campaignController.itemCampaignList != null ? SizedBox(
          height: 235,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: (campaignController.itemCampaignList!.length/5).ceil(),
                onPageChanged: (int index) => campaignController.setCurrentIndex(index, true),
                itemBuilder: (context, index) {
                  int index1 = index * 5;
                  int index2 = (index * 5) + 1;
                  int index3 = (index * 5) + 2;
                  int index4 = (index * 5) + 3;
                  int index5 = (index * 5) + 4;
                  return Row(children: [

                    Expanded(child: index1 < campaignController.itemCampaignList!.length ? campaignCart(context, index1, campaignController) : const SizedBox()),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(child: index2 < campaignController.itemCampaignList!.length ? campaignCart(context, index2, campaignController) : const SizedBox()),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(child: index3 < campaignController.itemCampaignList!.length ? campaignCart(context, index3, campaignController) : const SizedBox()),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(child: index4 < campaignController.itemCampaignList!.length ? campaignCart(context, index4, campaignController) : const SizedBox()),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(child: index5 < campaignController.itemCampaignList!.length ? campaignCart(context, index5, campaignController) : const SizedBox()),

                  ]);
                },
              ),

              campaignController.currentIndex != 0 ? Positioned(
                top: 0, bottom: 0, left: -10,
                child: InkWell(
                  onTap: () => pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  child: Container(
                    height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Theme.of(context).cardColor,
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    padding: const EdgeInsets.only(left: 10),
                    child: const Icon(Icons.arrow_back_ios),
                  ),
                ),
              ) : const SizedBox(),

              campaignController.currentIndex != ((campaignController.itemCampaignList!.length/5).ceil()-1) ? Positioned(
                top: 0, bottom: 0, right: -10,
                child: InkWell(
                  onTap: () => pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  child: Container(
                    height: 40, width: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Theme.of(context).cardColor,
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: const Icon(Icons.arrow_forward_ios_sharp),
                  ),
                ),
              ) : const SizedBox(),
            ],
          ),
        ) : WebPopularItemShimmer(campaignController: campaignController),

        // campaignController.itemCampaignList != null ? GridView.builder(
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 5, childAspectRatio: (1/1.1),
        //     mainAxisSpacing: Dimensions.paddingSizeLarge, crossAxisSpacing: Dimensions.paddingSizeLarge,
        //   ),
        //   physics: const NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        //   itemCount: campaignController.itemCampaignList!.length > 4 ? 5 : campaignController.itemCampaignList!.length,
        //   itemBuilder: (context, index){
        //     if(index == 4) {
        //       return InkWell(
        //         onTap: () => Get.toNamed(RouteHelper.getItemCampaignRoute()),
        //         child: Container(
        //           decoration: BoxDecoration(
        //             color: Theme.of(context).primaryColor,
        //             borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        //             border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.5)),
        //             // boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        //           ),
        //           alignment: Alignment.center,
        //           child: Text(
        //             '+${campaignController.itemCampaignList!.length-3}\n${'more'.tr}', textAlign: TextAlign.center,
        //             style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
        //           ),
        //         ),
        //       );
        //     }
        //
        //     return OnHover(
        //       isItem: true,
        //       child: InkWell(
        //         onTap: () {
        //           Get.find<ItemController>().navigateToItemPage(campaignController.itemCampaignList![index], context, isCampaign: true);
        //         },
        //         child: Container(
        //           decoration: BoxDecoration(
        //             color: Theme.of(context).cardColor,
        //             borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        //             border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.5)),
        //             // boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        //           ),
        //           child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        //
        //             Stack(children: [
        //               Padding(
        //                 padding: const EdgeInsets.all(1),
        //                 child: ClipRRect(
        //                   borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
        //                   child: CustomImage(
        //                     image: '${Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl}'
        //                         '/${campaignController.itemCampaignList![index].image}',
        //                     height: 135, fit: BoxFit.cover, width: context.width/4,
        //                   ),
        //                 ),
        //               ),
        //               DiscountTag(
        //                 discount: campaignController.itemCampaignList![index].storeDiscount! > 0
        //                     ? campaignController.itemCampaignList![index].storeDiscount
        //                     : campaignController.itemCampaignList![index].discount,
        //                 discountType: campaignController.itemCampaignList![index].storeDiscount! > 0 ? 'percent'
        //                     : campaignController.itemCampaignList![index].discountType,
        //                 fromTop: Dimensions.paddingSizeLarge, fontSize: Dimensions.fontSizeExtraSmall,
        //               ),
        //               Get.find<ItemController>().isAvailable(campaignController.itemCampaignList![index])
        //                   ? const SizedBox() : const NotAvailableWidget(),
        //             ]),
        //
        //             Expanded(
        //               child: Padding(
        //                 padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
        //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        //                   Text(
        //                     campaignController.itemCampaignList![index].name!,
        //                     style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
        //                     maxLines: 2, overflow: TextOverflow.ellipsis,
        //                   ),
        //                   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        //
        //                   Text(
        //                     campaignController.itemCampaignList![index].storeName!,
        //                     style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
        //                     maxLines: 1, overflow: TextOverflow.ellipsis,
        //                   ),
        //                   const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        //
        //                   Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                     children: [
        //                       Expanded(
        //                         child: Text(
        //                           PriceConverter.convertPrice(campaignController.itemCampaignList![index].price),
        //                           style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
        //                           textAlign: Get.find<LocalizationController>().isLtr ? TextAlign.left : TextAlign.right,
        //                         ),
        //                       ),
        //                       Icon(Icons.star, color: Theme.of(context).primaryColor, size: 12),
        //                       Text(
        //                         campaignController.itemCampaignList![index].avgRating!.toStringAsFixed(1),
        //                         style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
        //                       ),
        //                     ],
        //                   ),
        //                 ]),
        //               ),
        //             ),
        //
        //           ]),
        //         ),
        //       ),
        //     );
        //   },
        // ) : WebPopularItemShimmer(campaignController: campaignController),
      ],
    );
  }
}

Widget campaignCart(BuildContext context, int index, CampaignController campaignController) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
    child: OnHover(
      isItem: true,
      child: InkWell(
        onTap: () {
          Get.find<ItemController>().navigateToItemPage(campaignController.itemCampaignList![index], context, isCampaign: true);
        },
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
            // boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

            Stack(children: [
              Padding(
                padding: const EdgeInsets.all(1),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                  child: CustomImage(
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl}'
                        '/${campaignController.itemCampaignList![index].image}',
                    height: 135, fit: BoxFit.cover, width: context.width/4,
                  ),
                ),
              ),
              DiscountTag(
                discount: campaignController.itemCampaignList![index].storeDiscount! > 0
                    ? campaignController.itemCampaignList![index].storeDiscount
                    : campaignController.itemCampaignList![index].discount,
                discountType: campaignController.itemCampaignList![index].storeDiscount! > 0 ? 'percent'
                    : campaignController.itemCampaignList![index].discountType,
                fromTop: Dimensions.paddingSizeLarge, fontSize: Dimensions.fontSizeExtraSmall,
              ),
              Get.find<ItemController>().isAvailable(campaignController.itemCampaignList![index])
                  ? const SizedBox() : const NotAvailableWidget(),
            ]),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    campaignController.itemCampaignList![index].name!,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text(
                    campaignController.itemCampaignList![index].storeName!,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          PriceConverter.convertPrice(campaignController.itemCampaignList![index].price),
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                          textAlign: Get.find<LocalizationController>().isLtr ? TextAlign.left : TextAlign.right,
                        ),
                      ),
                      Icon(Icons.star, color: Theme.of(context).primaryColor, size: 12),
                      Text(
                        campaignController.itemCampaignList![index].avgRating!.toStringAsFixed(1),
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ]),
              ),
            ),

          ]),
        ),
      ),
    ),
  );
}

class WebPopularItemShimmer extends StatelessWidget {
  final CampaignController campaignController;
  const WebPopularItemShimmer({Key? key, required this.campaignController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, childAspectRatio: (1/1.1),
        mainAxisSpacing: Dimensions.paddingSizeLarge, crossAxisSpacing: Dimensions.paddingSizeLarge,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      itemCount: 5,
      itemBuilder: (context, index){
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 10, spreadRadius: 1)],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: campaignController.itemCampaignList == null,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                height: 135,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                  color: Colors.grey[300],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 15, width: 100, color: Colors.grey[300]),
                    const SizedBox(height: 5),

                    Container(height: 10, width: 130, color: Colors.grey[300]),
                    const SizedBox(height: 5),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(height: 10, width: 30, color: Colors.grey[300]),
                      const RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                    ]),
                  ]),
                ),
              ),

            ]),
          ),
        );
      },
    );
  }
}

