import 'package:flutter/material.dart';

import 'package:flutter/material.dart' hide Banner;
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/corner_banner/banner.dart';
import 'package:citgroupvn_ecommerce/view/base/corner_banner/positioned_banner.dart';

/// A [CornerBanner] that displays "Built with" and the Flutter logo, to
/// let the world know that your product is built with Flutter.
class CornerDiscountTag extends StatelessWidget {
  const CornerDiscountTag.positioned({
    Key? key, required this.bannerPosition,
    this.elevation = 0, this.shadowColor = const Color(0xCC000000), required this.discount,
    required this.discountType, this.fontSize, this.freeDelivery = false,
  })  : isPositioned = true,
        super(key: key);

  const CornerDiscountTag({
    Key? key, required this.bannerPosition,
    this.elevation = 0, this.shadowColor = const Color(0xCC000000), required this.discount,
    required this.discountType, this.fontSize, this.freeDelivery = false,
  })  : isPositioned = false,
        super(key: key);

  final bool isPositioned;
  final CornerBannerPosition bannerPosition;
  final double elevation;
  final Color shadowColor;
  final double? discount;
  final String? discountType;
  final double? fontSize;
  final bool? freeDelivery;

  @override
  Widget build(BuildContext context) {
    if (isPositioned) {
      return PositionedCornerBanner(
        bannerPosition: bannerPosition,
        bannerColor: Theme.of(context).colorScheme.error,
        elevation: elevation,
        shadowColor: shadowColor,
        child: _buildBannerContent(),
      );
    } else {
      return (discount! > 0 || freeDelivery!) ? CornerBanner(
        bannerPosition: bannerPosition,
        bannerColor: Theme.of(context).colorScheme.error,
        elevation: 5,
        shadowColor: Colors.transparent,
        child: _buildBannerContent(),
      ) : const SizedBox();
    }
  }

  Widget _buildBannerContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0,),
      child: Material(
        // Material prevents ugly text display when there is no
        // Scaffold above this banner.
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:  [
                Text(
                  discount! > 0 ? '$discount${discountType == 'percent' ? '%'
                      : Get.find<SplashController>().configModel!.currencySymbol} ${'off'.tr}' : 'free_delivery'.tr,
                  style: robotoMedium.copyWith(
                    color: Colors.white,
                    fontSize: fontSize ?? (ResponsiveHelper.isMobile(Get.context) ? 8 : 12),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
