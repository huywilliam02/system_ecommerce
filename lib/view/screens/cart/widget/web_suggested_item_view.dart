import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/cart_controller.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/cart_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/item_widget.dart';

class WebSuggestedItemView extends StatelessWidget {
  final List<CartModel> cartList;
  const WebSuggestedItemView({Key? key, required this.cartList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return SizedBox(
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        GetBuilder<StoreController>(builder: (storeController) {
          List<Item>? suggestedItems;
          if(storeController.cartSuggestItemModel != null){
            suggestedItems = [];
            List<int> cartIds = [];
            for (CartModel cartItem in cartList) {
              cartIds.add(cartItem.item!.id!);
            }
            for (Item item in storeController.cartSuggestItemModel!.items!) {
              if(!cartIds.contains(item.id)){
                suggestedItems.add(item);
              }
            }
          }
          return storeController.cartSuggestItemModel != null && suggestedItems!.isNotEmpty ? GetBuilder<CartController>(
            builder: (cartController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                    child: Text('you_may_also_like'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  ),

                  SizedBox(
                    height: ResponsiveHelper.isDesktop(context) ? 110 : 125,
                    child: PageView.builder (
                      controller: pageController,
                      itemCount: (suggestedItems!.length/4).ceil(),
                      itemBuilder: (context, index) {
                        int index1 = index * 4;
                        int index2 = (index * 4) + 1;
                        int index3 = (index * 4) + 2;
                        int index4 = (index * 4) + 3;
                        bool hasSecond = index2 < suggestedItems!.length;
                        bool hasThird = index3 < suggestedItems.length;
                        bool hasFourth = index4 < suggestedItems.length;
                        return Stack(
                          children: [
                            Row(
                              children: [

                                Container(
                                  width: 282.5,
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  child: ItemWidget(
                                      imageHeight: 90, imageWidth: 90, isCornerTag: true,
                                      isStore: false, item: suggestedItems[index1], fromCartSuggestion: true,
                                      store: null, index: index, length: null, isCampaign: false, inStore: true,
                                    ),
                                ),

                                hasSecond ? Container(
                                  width: 282.5,
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  child: ItemWidget(
                                  imageHeight: 90, imageWidth: 90, isCornerTag: true,
                                  isStore: false, item: suggestedItems[index2], fromCartSuggestion: true,
                                  store: null, index: index, length: null, isCampaign: false, inStore: true,
                                  ),
                                ) : const SizedBox(),

                                hasThird ? Container(
                                  width: 282.5,
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  child: ItemWidget(
                                  imageHeight: 90, imageWidth: 90, isCornerTag: true,
                                  isStore: false, item: suggestedItems[index3], fromCartSuggestion: true,
                                  store: null, index: index, length: null, isCampaign: false, inStore: true,
                                  ),
                                ) : const SizedBox(),

                                hasFourth ? Container(
                                  width: 282.5,
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  child: ItemWidget(
                                  imageHeight: 90, imageWidth: 90, isCornerTag: true,
                                  isStore: false, item: suggestedItems[index4], fromCartSuggestion: true,
                                  store: null, index: index, length: null, isCampaign: false, inStore: true,
                                  ),
                                ) : const SizedBox(),
                              ],
                            ),


                            cartController.currentIndex != 0 ? Positioned(
                              top: 0, bottom: 0, left: 0,
                              child: InkWell(
                                onTap: () => pageController.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                                child: Container(
                                  height: 30, width: 30, alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: Theme.of(context).cardColor,
                                  ),
                                  child: const Icon(Icons.keyboard_arrow_left),
                                ),
                              ),
                            ) : const SizedBox(),

                            cartController.currentIndex != ((suggestedItems.length/4).ceil()-1) ? Positioned(
                              top: 0, bottom: 0, right: 0,
                              child: InkWell(
                                onTap: () => pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut),
                                child: Container(
                                  height: 30, width: 30, alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: Theme.of(context).cardColor,
                                  ),
                                  child: const Icon(Icons.keyboard_arrow_right),
                                ),
                              ),
                            ) : const SizedBox(),
                          ],
                        );
                      },
                      onPageChanged: (int index) => cartController.setCurrentIndex(index, true),
                    )
                  ),
                ],
              );
            }
          ) : const SizedBox();
        }),
      ]),
    );
  }
}





// ListView.builder(
//   scrollDirection: Axis.horizontal,
//   itemCount: suggestedItems.length,
//   physics: const BouncingScrollPhysics(),
//   padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
//   itemBuilder: (context, index) {
//     return Padding(
//       padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 10) ,
//       child: Container(
//         width: 300,
//         padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
//         margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
//         child: ItemWidget(
//           imageHeight: 90, imageWidth: 90, isCornerTag: true,
//           isStore: false, item: suggestedItems![index], fromCartSuggestion: true,
//           store: null, index: index, length: null, isCampaign: false, inStore: true,
//         ),
//       ),
//     );
//   },
// ),