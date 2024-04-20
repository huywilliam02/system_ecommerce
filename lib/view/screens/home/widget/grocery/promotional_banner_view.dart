import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:citgroupvn_ecommerce/controller/banner_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/video_content_model.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';

class PromotionalBannerView extends StatelessWidget {
  const PromotionalBannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeDefault),
        child: bannerController.promotionalBanner != null ? Container(
          height: 90, width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            child: CustomImage(
              image: '${bannerController.promotionalBanner!.promotionalBannerUrl}/${bannerController.promotionalBanner!.bottomSectionBanner}',
              fit: BoxFit.cover, height: 80, width: double.infinity,
            ),
          ),
        ) : const PromotionalBannerShimmerView(),
      );
    });
  }
}

class PromotionalBannerShimmerView extends StatelessWidget {
  const PromotionalBannerShimmerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        height: 90, width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
      ),
    );
  }
}