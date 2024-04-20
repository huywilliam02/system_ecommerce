import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:citgroupvn_ecommerce/controller/flash_sale_controller.dart';
import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/screens/flash_sale/flash_sale_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/grocery/widget/components/flash_sale_card.dart';
import 'package:citgroupvn_ecommerce/view/screens/flash_sale/widgets/flash_sale_timer_view.dart';

class WebFlashSaleView extends StatefulWidget {
  const WebFlashSaleView({Key? key}) : super(key: key);

  @override
  State<WebFlashSaleView> createState() => _WebFlashSaleViewState();
}

class _WebFlashSaleViewState extends State<WebFlashSaleView> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlashSaleController>(builder: (flashSaleController) {
      Item? item;
      int stock = 0;
      int remaining = 0;
      if(flashSaleController.flashSaleModel != null && flashSaleController.flashSaleModel!.activeProducts != null) {
        item = flashSaleController.flashSaleModel!.activeProducts![flashSaleController.pageIndex].item;
        stock = flashSaleController.flashSaleModel!.activeProducts![flashSaleController.pageIndex].stock!;
        int sold = flashSaleController.flashSaleModel!.activeProducts![flashSaleController.pageIndex].sold!;
        remaining = stock - sold;
      }

      return flashSaleController.flashSaleModel != null ? flashSaleController.flashSaleModel!.activeProducts != null ? Container(
        width: Get.width,
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 2),
        ),
        child: Column(children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkWell(
                onTap: () => Get.toNamed(RouteHelper.getFlashSaleDetailsScreen(0)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('flash_sale'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  //Text('limited_time_offer'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                ]),
              ),
              //const SizedBox(width: Dimensions.paddingSizeSmall),
              const Spacer(),

              FlashSaleTimerView(eventDuration: flashSaleController.duration),
            ]),
          ),

          flashSaleController.flashSaleModel!.activeProducts != null ? FlashSaleCard(
            activeProducts: flashSaleController.flashSaleModel!.activeProducts!, soldOut: remaining == 0,
          ) : const SizedBox(),

          Text("${item!.name}", style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis,),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          /*(Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item.unitType != null) ? Text(
            '(${ item.unitType ?? ''})',
            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
          ) : const SizedBox(),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),*/

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [

            item.discount != null && item.discount! > 0  ? Flexible(child: Text(
              PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                decoration: TextDecoration.lineThrough,
              ), textDirection: TextDirection.ltr,
            )) : const SizedBox(),
            SizedBox(width: item.discount != null && item.discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

            Flexible(child: Text(
              PriceConverter.convertPrice(
                Get.find<ItemController>().getStartingPrice(item), discount: item.discount,
                discountType: item.discountType,
              ),
              textDirection: TextDirection.ltr, style: robotoMedium,
            )),
          ]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          /*Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtremeLarge),
            child: LinearProgressIndicator(
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              minHeight: 5,
              value: remaining / stock,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.25),
            ),
          ),*/

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${'available'.tr} : ', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
            Text('$remaining ${'item'.tr}', style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ]),
      ) : const SizedBox() : const WebFlashSaleShimmerView();
    });
  }
}

class WebFlashSaleShimmerView extends StatelessWidget {
  const WebFlashSaleShimmerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        width: Get.width, height: 302,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
      ),
    );
  }
}
