import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/title_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/grocery/widget/components/popular_store_card.dart';

import '../../web/web_new/web_populer_store_view.dart';


class PopularStoreView extends StatelessWidget {
  const PopularStoreView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: GetBuilder<StoreController>(builder: (storeController) {
        List<Store>? storeList = storeController.popularStoreList;

          return Column(children: [
            Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
              child: TitleWidget(
                title: 'popular_stores'.tr,
                onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute('popular')),
              ),
            ),

            SizedBox(
              height: 170,
              child: storeList != null ? ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: storeList.length,
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
                    child: PopularStoreCard(
                      store: storeList[index],
                    ),
                  );
                },
              ) : const PopularStoreShimmer(),
            ),

          ]);
        }
      ),
    );
  }
}

