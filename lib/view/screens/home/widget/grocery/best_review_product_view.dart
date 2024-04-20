import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/grocery/widget/components/review_item_card.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/widgets/sorting_text_button.dart';

class BestReviewedProductView extends StatelessWidget {
  const BestReviewedProductView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('best_reviewed_products'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Row(mainAxisAlignment : MainAxisAlignment.spaceBetween, children: [
              SortingTextButton(
                title: 'all'.tr,
                onTap: () {},
              ),

              SortingTextButton(
                title: 'beauty'.tr,
                onTap: () {},
              ),

              SortingTextButton(
                title: 'men_fashion'.tr,
                onTap: () {},
              ),

              SortingTextButton(
                title: 'women_fashion'.tr,
                onTap: () {},
              ),

              SortingTextButton(
                title: 'electronics'.tr,
                onTap: () {},
              ),

            ]),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withOpacity(0.1),
            ),
            child: SizedBox(
              height: 280, width: Get.width,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                itemCount: 10,
                itemBuilder: (context, index) {
                  const int cartQty = 0;
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : Dimensions.paddingSizeDefault),
                    child: const ReviewItemCard(),
                  );
                },
              ),
            ),
          ),
        ),

      ]),
    );
  }
}




