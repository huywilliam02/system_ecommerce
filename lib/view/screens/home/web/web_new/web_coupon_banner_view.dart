import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/coupon_controller.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/grocery/promo_code_banner_view.dart';

class WebCouponBannerView extends StatefulWidget {
  const WebCouponBannerView({Key? key}) : super(key: key);

  @override
  State<WebCouponBannerView> createState() => _WebCouponBannerViewState();
}

class _WebCouponBannerViewState extends State<WebCouponBannerView> {

  final CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CouponController>(builder: (couponController) {

      return couponController.couponList != null ? couponController.couponList!.isNotEmpty ? Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraLarge),
        child: Column(children: [

          CarouselSlider.builder(
            carouselController: carouselController,
            itemCount: couponController.couponList!.length,
            options: CarouselOptions(
              height: 135,
              enlargeCenterPage: true,
              disableCenter: true,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                couponController.setCurrentIndex(index, true);
              },
            ),
            itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
              return Container(
                height: 135, width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  image: const DecorationImage(
                    image: AssetImage(Images.promoCodeBg),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Row(children: [
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(Images.couponOfferIcon, height: 92, width: 115),
                        const SizedBox(width: 50),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              couponController.couponList![itemIndex].title ?? '',
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.8)),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Row(
                              children: [
                                Text(
                                  'min_order_of'.tr,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.8)),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                Text(
                                  PriceConverter.convertPrice(couponController.couponList![itemIndex].minPurchase),
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.8)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  const Spacer(),

                  DottedBorder(
                    color: Theme.of(context).primaryColor,
                    strokeWidth: 1,
                    strokeCap: StrokeCap.butt,
                    dashPattern: const [5, 5],
                    padding: const EdgeInsets.all(0),
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(50),
                    child: InkWell(
                      onTap: () {
                        if(couponController.couponList![itemIndex].code != null){
                          Clipboard.setData(ClipboardData(text: couponController.couponList![itemIndex].code ?? ''));
                          showCustomSnackBar('coupon_code_copied'.tr, isError: false);
                        }
                      },
                      child: Container(
                        height: 35, width: 130,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.copy, color: Theme.of(context).primaryColor, size: 16),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text(couponController.couponList![itemIndex].code ?? '', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                ]),
              );
            },
          ),
        ]),
      ) : const SizedBox() : const PromoCodeShimmerView();
    });
  }
}
