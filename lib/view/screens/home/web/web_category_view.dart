import 'package:citgroupvn_ecommerce/controller/category_controller.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:citgroupvn_ecommerce/view/base/hover/on_hover.dart';
import 'package:citgroupvn_ecommerce/view/base/hover/text_hover.dart';
import 'package:citgroupvn_ecommerce/view/base/title_widget.dart';

class WebCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const WebCategoryView({Key? key, required this.categoryController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Padding(
        padding: EdgeInsets.only(
          top: Dimensions.paddingSizeSmall,
          left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeExtraSmall : 0,
          right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeExtraSmall,
        ),
        child: TitleWidget(title: 'categories'.tr),
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      SizedBox(
        height: 170,
        child: categoryController.categoryList != null ? ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
          itemCount: categoryController.categoryList!.length > 9 ? 10 : categoryController.categoryList!.length,
          itemBuilder: (context, index) {

            if(index == 9) {
              return TextHover(
                builder: (hovered) {
                  return InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getCategoryRoute()),
                    child: Container(
                      width: 108,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                      child: Column(children: [

                        Container(
                          height: 80, width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Icon(Icons.arrow_forward, color: Theme.of(context).cardColor),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(
                          'view_all'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: hovered ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),

                      ]),
                    ),
                  );
                }
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: () => Get.toNamed(RouteHelper.getCategoryItemRoute(
                  categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
                )),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: OnHover(
                  isItem: true,
                  child: TextHover(
                    builder: (hovered) {
                      return Container(
                        width: 108,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
                        ),
                        child: Column(children: [

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 0.5)
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImage(
                                image: '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.categoryList![index].image}',
                                height: 80, width: double.infinity, fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Expanded(child: Text(
                            categoryController.categoryList![index].name!,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: hovered ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor),
                            maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                          )),

                        ]),
                      );
                    }
                  ),
                ),
              ),
            );
          },
        ) : WebCategoryShimmer(categoryController: categoryController),
      ),

    ]);
  }
}

class WebCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const WebCategoryShimmer({Key? key, required this.categoryController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
            child: Container(
              width: 108,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              child: Shimmer(
                duration: const Duration(seconds: 2),
                enabled: categoryController.categoryList == null,
                child: Column(children: [

                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[300]),
                    height: 80, width: 70,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Container(height: 15, width: 150, color: Colors.grey[300]),

                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

