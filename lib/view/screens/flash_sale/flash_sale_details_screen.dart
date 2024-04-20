import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:citgroupvn_ecommerce/controller/flash_sale_controller.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/paginated_list_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/flash_sale/widgets/flash_product_card.dart';
import 'package:citgroupvn_ecommerce/view/screens/flash_sale/widgets/flash_sale_timer_view.dart';

class FlashSaleDetailsScreen extends StatefulWidget {
  final int id;
  const FlashSaleDetailsScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<FlashSaleDetailsScreen> createState() => _FlashSaleDetailsScreenState();
}

class _FlashSaleDetailsScreenState extends State<FlashSaleDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<FlashSaleController>().getFlashSaleWithId(1, false, widget.id);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'flash_sale'.tr),
      body: Center(
        child: GetBuilder<FlashSaleController>(
            builder: (flashSaleController) {
              return Column(children: [
                SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : 0),
                Container(
                  width: Dimensions.webMaxWidth,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
                    border: Border.symmetric(
                      horizontal: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 2),
                      vertical: BorderSide(color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).primaryColor.withOpacity(0.2) : Theme.of(context).primaryColor.withOpacity(0.2), width: 2),
                    ),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('flash_sale'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text(
                        'limited_time_offer'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                    ]),

                    FlashSaleTimerView(eventDuration: flashSaleController.duration),
                  ]),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: FooterView(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: PaginatedListView(
                          scrollController: _scrollController,
                          totalSize: flashSaleController.productFlashSale != null ? flashSaleController.productFlashSale!.totalSize : null,
                          offset: flashSaleController.productFlashSale != null
                              ? flashSaleController.productFlashSale!.offset
                              : null,
                          onPaginate: (int? offset) async => await flashSaleController.getFlashSaleWithId(offset!, false, widget.id),
                          itemView: flashSaleController.productFlashSale != null ? GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 340 : 240,
                            ),
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: flashSaleController.productFlashSale!.products!.length,
                            padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeDefault,
                            ),
                            itemBuilder: (context, index) {
                              return FlashProductCard(product: flashSaleController.productFlashSale!.products![index]);
                            },
                          ) : const FlashProductCardShimmer(),
                        ),
                      ),
                    ),
                  ),
                ),
              ]);
            }
        ),
      ),
    );
  }
}

class FlashProductCardShimmer extends StatelessWidget {
  const FlashProductCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 3 : 2,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 340 : 240,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: ResponsiveHelper.isDesktop(context) ? 5 : 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: Container(
                    width: double.infinity, height: double.infinity,
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : 0),

              Expanded(
                flex: ResponsiveHelper.isDesktop(context) ? 3 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Container(
                        height: 10, width: 100,
                        color: Theme.of(context).cardColor,
                      ),
                      //const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        height: 10, width: 200,
                        color: Theme.of(context).cardColor,
                      ),
                      //const SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        height: 10, width: 100,
                        color: Theme.of(context).cardColor,
                      ),

                    ],
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}


