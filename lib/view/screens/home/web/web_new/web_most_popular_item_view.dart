import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/view/base/title_widget.dart';
import 'package:citgroupvn_ecommerce/view/base/card_design/item_card.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_special_offer_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/widgets/arrow_icon_button.dart';

class WebMostPopularItemView extends StatefulWidget {
  final bool isFood;
  final bool isShop;
  const WebMostPopularItemView({Key? key, required this.isFood, required this.isShop}) : super(key: key);

  @override
  State<WebMostPopularItemView> createState() => _WebMostPopularItemViewState();
}

class _WebMostPopularItemViewState extends State<WebMostPopularItemView> {

  ScrollController scrollController = ScrollController();
  bool showBackButton = false;
  bool showForwardButton = false;
  bool isFirstTime = true;

  @override
  void initState() {
    scrollController.addListener(_checkScrollPosition);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    setState(() {
      if (scrollController.position.pixels <= 0) {
        showBackButton = false;
      } else {
        showBackButton = true;
      }

      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        showForwardButton = false;
      } else {
        showForwardButton = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;

    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? itemList = itemController.popularItemList;

      if(itemList != null && itemList.length > 5 && isFirstTime){
        showForwardButton = true;
        isFirstTime = false;
      }

      return itemList != null ? itemList.isNotEmpty ? Stack(children: [

        Container(
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Column(children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeExtremeLarge),
              child: TitleWidget(
                title: isShop ? 'most_popular_products'.tr : 'most_popular_items'.tr,
                image: Images.mostPopularIcon,
                onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(true, false)),
              ),
            ),

            SizedBox(
              height: 285, width: Get.width,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraLarge),
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraLarge, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeExtraSmall),
                    child: ItemCard(
                      isPopularItem: isShop ? false : true,
                      isPopularItemCart: true,
                      item: itemList[index],
                      isFood: widget.isFood,
                      isShop: widget.isShop,
                    ),
                  );
                },
              ),
            ),

          ]),
        ),

        if(showBackButton)
          Positioned(
            top: 200, left: 0,
            child: ArrowIconButton(
              isRight: false,
              onTap: () => scrollController.animateTo(scrollController.offset - Dimensions.webMaxWidth,
                  duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
            ),
          ),

        if(showForwardButton)
          Positioned(
            top: 200, right: 0,
            child: ArrowIconButton(
              onTap: () => scrollController.animateTo(scrollController.offset + Dimensions.webMaxWidth,
                  duration: const Duration(milliseconds: 500), curve: Curves.easeInOut),
            ),
          ),

      ]) : const SizedBox() : WebItemShimmerView(itemController: itemController, isPopularItem: true);
    });
  }
}
