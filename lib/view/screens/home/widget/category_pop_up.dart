import 'package:citgroupvn_ecommerce/controller/category_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class CategoryPopUp extends StatelessWidget {
  final CategoryController categoryController;
  const CategoryPopUp({Key? key, required this.categoryController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 500,
        height: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 0, 10),
              child:
              TitleWidget(title: 'categories'.tr),
            ),
            Expanded(
              child: SizedBox(
                height: 80,
                child: categoryController.categoryList != null ? GridView.builder(
                  itemCount: categoryController.categoryList!.length,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1.2,
                    crossAxisCount: GetPlatform.isDesktop ? 5 : 4,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getCategoryItemRoute(
                          categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
                        )),
                        child: SizedBox(
                          width: 50,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50, width: 50,
                                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
                                  ),
                                  child: CustomImage(
                                    image: '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.categoryList![index].image}',
                                    height: 50, width: 50, fit: BoxFit.cover,
                                  ),
                                ),
                                Text(
                                  categoryController.categoryList![index].name!,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                ),
                              ]),
                        ),
                      ),
                    );
                  },
                ) : CategoryShimmer(categoryController: categoryController),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const CategoryShimmer({Key? key, required this.categoryController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        itemCount: 10,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: categoryController.categoryList == null,
              child: Column(children: [
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                    height: 10, width: 50, color: Colors.grey[300]),
              ]),
            ),
          );
        },
      ),
    );
  }
}
