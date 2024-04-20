import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/discount_tag.dart';
import 'package:citgroupvn_ecommerce/view/base/hover/on_hover.dart';
import 'package:citgroupvn_ecommerce/view/base/not_available_widget.dart';
import 'package:citgroupvn_ecommerce/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class WebPopularItemView extends StatelessWidget {
  final bool isPopular;
  final ItemController itemController;
  final bool showInSlider;
  const WebPopularItemView({Key? key, required this.itemController, required this.isPopular, this.showInSlider = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    List<Item>? itemList = isPopular ? itemController.popularItemList : itemController.reviewedItemList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Text(isPopular ? 'popular_items_nearby'.tr : 'best_reviewed_item'.tr, style: robotoMedium.copyWith(fontSize: 24)),
        ),

        itemList != null ? !isPopular ? SizedBox(
          height: 130,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: (itemList.length/4).ceil(),
                onPageChanged: (int index) => itemController.setCurrentIndex(index, true),
                itemBuilder: (context, index) {
                  int index1 = index * 4;
                  int index2 = (index * 4) + 1;
                  int index3 = (index * 4) + 2;
                  int index4 = (index * 4) + 3;
                  return Row(children: [

                    Expanded(child: index1 < itemList.length ? itemCartWidget(context, index1, itemController, itemList) : const SizedBox()),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: index2 < itemList.length ? itemCartWidget(context, index2, itemController, itemList) : const SizedBox()),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: index3 < itemList.length ? itemCartWidget(context, index3, itemController, itemList) : const SizedBox()),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: index4 < itemList.length ? itemCartWidget(context, index4, itemController, itemList) : const SizedBox()),

                  ]);
                },
              ),

              itemController.currentIndex != 0 ? Positioned(
                top: 0, bottom: 0, left: -10,
                child: InkWell(
                  onTap: () => pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  hoverColor: Colors.transparent,
                  child: OnHover(
                    child: Container(
                      height: 40, width: 40, alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Theme.of(context).cardColor,
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
                      ),
                      padding: const EdgeInsets.only(left: 10),
                      child: const Icon(Icons.arrow_back_ios),
                    ),
                  ),
                ),
              ) : const SizedBox(),

              itemController.currentIndex != ((itemList.length/4).ceil()-1) ? Positioned(
                top: 0, bottom: 0, right: -10,
                child: InkWell(
                  onTap: () => pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                  hoverColor: Colors.transparent,
                  child: OnHover(
                    child: Container(
                      height: 40, width: 40, alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Theme.of(context).cardColor,
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
                      ),
                      child: const Icon(Icons.arrow_forward_ios_sharp),
                    ),
                  ),
                ),
              ) : const SizedBox(),
            ],
          ),
        ) : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, childAspectRatio: (1/0.365),
            crossAxisSpacing: Dimensions.paddingSizeLarge, mainAxisSpacing: Dimensions.paddingSizeLarge,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          itemCount: itemList.length > 7 ? 8 : itemList.length,
          itemBuilder: (context, index){

            return OnHover(
              isItem: true,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      Get.find<ItemController>().navigateToItemPage(itemList[index], context);
                    },
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
                      ),
                      child: Row(children: [

                        Stack(children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(color: Theme.of(context).disabledColor, width: 0.1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImage(
                                image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                                    '/${itemList[index].image}',
                                height: 90, width: 90, fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          DiscountTag(
                            discount: itemController.getDiscount(itemList[index]),
                            discountType: itemController.getDiscountType(itemList[index]),
                          ),
                          itemController.isAvailable(itemList[index]) ? const SizedBox() : const NotAvailableWidget(),
                        ]),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(
                                itemList[index].name!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              Text(
                                itemList[index].storeName!,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              RatingBar(
                                rating: itemList[index].avgRating, size: 15,
                                ratingCount: itemList[index].ratingCount,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Row(
                                children: [
                                  Text(
                                    PriceConverter.convertPrice(
                                      itemList[index].price, discount: itemList[index].discount, discountType: itemList[index].discountType,
                                    ), textDirection: TextDirection.ltr,
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                  ),
                                  SizedBox(width: itemList[index].discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                  itemList[index].discount! > 0 ? Expanded(child: Text(
                                    PriceConverter.convertPrice(itemController.getStartingPrice(itemList[index])),
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                      decoration: TextDecoration.lineThrough,
                                    ), textDirection: TextDirection.ltr,
                                  )) : const Expanded(child: SizedBox()),
                                  const Icon(Icons.add, size: 25),
                                ],
                              ),
                            ]),
                          ),
                        ),

                      ]),
                    ),
                  ),

                  Visibility(
                    visible: index == 7,
                    child: Positioned(
                      top: 0, bottom: 0, left: 0, right: 0,
                      child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(isPopular, false)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                            gradient: LinearGradient(colors: [
                              Theme.of(context).primaryColor.withOpacity(0.7),
                              Theme.of(context).primaryColor.withOpacity(1),
                            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '+${itemList.length-5}\n${'more'.tr}', textAlign: TextAlign.center,
                            style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ) : WebCampaignShimmer(enabled: itemList == null, isPopular: isPopular),
      ],
    );
  }
}

Widget itemCartWidget(BuildContext context, int index, ItemController itemController, List<Item> itemList) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeExtraSmall),
    child: OnHover(
      isItem: true,
      child: InkWell(
        onTap: () {
          Get.find<ItemController>().navigateToItemPage(itemList[index], context);
        },
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.15)),
          ),
          child: Row(children: [

            Stack(children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).disabledColor, width: 0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImage(
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                        '/${itemList[index].image}',
                    height: 90, width: 90, fit: BoxFit.cover,
                  ),
                ),
              ),
              DiscountTag(
                discount: itemController.getDiscount(itemList[index]),
                discountType: itemController.getDiscountType(itemList[index]),
              ),
              itemController.isAvailable(itemList[index]) ? const SizedBox() : const NotAvailableWidget(),
            ]),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    itemList[index].name!,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    itemList[index].storeName!,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  RatingBar(
                    rating: itemList[index].avgRating, size: 15,
                    ratingCount: itemList[index].ratingCount,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(
                    children: [
                      Text(
                        PriceConverter.convertPrice(
                          itemList[index].price, discount: itemList[index].discount, discountType: itemList[index].discountType,
                        ), textDirection: TextDirection.ltr,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),
                      SizedBox(width: itemList[index].discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
                      itemList[index].discount! > 0 ? Expanded(child: Text(
                        PriceConverter.convertPrice(itemController.getStartingPrice(itemList[index])),
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                          decoration: TextDecoration.lineThrough,
                        ), textDirection: TextDirection.ltr,
                      )) : const Expanded(child: SizedBox()),
                      const Icon(Icons.add, size: 25),
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

class WebCampaignShimmer extends StatelessWidget {
  final bool enabled;
  final bool isPopular;
  const WebCampaignShimmer({Key? key, required this.enabled, required this.isPopular}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, childAspectRatio: (1/0.35),
        crossAxisSpacing: Dimensions.paddingSizeLarge, mainAxisSpacing: Dimensions.paddingSizeLarge,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      itemCount: !isPopular ? 4 : 8,
      itemBuilder: (context, index){
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: enabled,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                height: 90, width: 90,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[300]),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 15, width: 100, color: Colors.grey[300]),
                    const SizedBox(height: 5),

                    Container(height: 10, width: 130, color: Colors.grey[300]),
                    const SizedBox(height: 5),

                    const RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                    const SizedBox(height: 5),

                    Container(height: 10, width: 30, color: Colors.grey[300]),
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

