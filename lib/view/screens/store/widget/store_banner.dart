import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:url_launcher/url_launcher_string.dart';
class StoreBanner extends StatelessWidget {
  final StoreController storeController;
  const StoreBanner({Key? key, required this.storeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (storeController.storeBanners != null && storeController.storeBanners!.isNotEmpty) ? Container(
      height: context.width * 0.3, width: double.infinity,
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: CarouselSlider.builder(
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          disableCenter: true,
          viewportFraction: 1,
          autoPlayInterval: const Duration(seconds: 4),
        ),
        itemCount: storeController.storeBanners!.length,
        itemBuilder: (context, index, _) {
          return InkWell(
            onTap: () async {
              String url = storeController.storeBanners![index].defaultLink!;
              if (await canLaunchUrlString(url)) {
              await launchUrlString(url, mode: LaunchMode.externalApplication);
              }else {
              showCustomSnackBar('unable_to_found_url'.tr);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomImage(image: '${ Get.find<SplashController>().configModel!.baseUrls!.bannerImageUrl}/${storeController.storeBanners![index].image}'),
            ),
          );
        },
      ),
    ) : const SizedBox();
  }
}
