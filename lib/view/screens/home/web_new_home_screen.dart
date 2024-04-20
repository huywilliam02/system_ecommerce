import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/banner_controller.dart';
import 'package:citgroupvn_ecommerce/controller/campaign_controller.dart';
import 'package:citgroupvn_ecommerce/controller/category_controller.dart';
import 'package:citgroupvn_ecommerce/controller/flash_sale_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/item_view.dart';
import 'package:citgroupvn_ecommerce/view/base/paginated_list_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/dashboard/widget/address_bottom_sheet.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/module_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/middle_section_multiple_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_basic_medicine_nearby_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_best_review_item_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_best_store_nearby_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_category_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_common_condition_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_coupon_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_featured_categories_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_flash_sale_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_item_that_you_love_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_just_for_you_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_most_popular_item_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_most_popular_item_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_new_on_mart_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_new_on_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_populer_store_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_recomanded_store_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_special_offer_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_promotional_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_visit_again_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/widgets/store_sorting_button.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/web/web_new/web_new_banner_view.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/widget/bad_weather_widget.dart';

class WebNewHomeScreen extends StatefulWidget {
  final ScrollController scrollController;
  const WebNewHomeScreen({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<WebNewHomeScreen> createState() => _WebNewHomeScreenState();
}

class _WebNewHomeScreenState extends State<WebNewHomeScreen> {

  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();
    _isLogin = Get.find<AuthController>().isLoggedIn();
    Get.find<SplashController>().getWebSuggestedLocationStatus();

    if(_isLogin){
      suggestAddressBottomSheet();
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if(!Get.find<SplashController>().webSuggestedLocation && active){
      Future.delayed(const Duration(seconds: 1), () {
        Get.dialog( const Center(child: SizedBox(height: 470, width: 550, child: AddressBottomSheet(fromDialog: true))));
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    bool isFood = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.food;
    bool isShop = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce;
    Get.find<BannerController>().setCurrentIndex(0, false);
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Stack(clipBehavior: Clip.none, children: [

      SizedBox(height: context.height),

      SingleChildScrollView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [

          FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(crossAxisAlignment : CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(
                flex: 3,
                child: GetBuilder<BannerController>(builder: (bannerController) {
                  return bannerController.bannerImageList == null ?  const WebNewBannerView(isFeatured: false)
                      : bannerController.bannerImageList!.isEmpty ? const SizedBox() : const WebNewBannerView(isFeatured: false);
                }),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              GetBuilder<StoreController>(
                builder: (storeController) {
                  return GetBuilder<FlashSaleController>(
                    builder: (flashController) {
                      bool isFlashSaleActive = (flashController.flashSaleModel?.activeProducts != null && flashController.flashSaleModel!.activeProducts!.isNotEmpty);
                      bool showRecommendedStore = storeController.recommendedStoreList != null && storeController.recommendedStoreList!.isNotEmpty;
                      return Expanded(
                        flex: 1,
                          child: isFlashSaleActive ? const WebFlashSaleView() : const WebRecommendedStoreView(),
                      );
                    }
                  );
                }
              ),
            ]),

            const BadWeatherWidget(),

            GetBuilder<CategoryController>(builder: (categoryController) {
              return categoryController.categoryList == null ? WebCategoryView(categoryController: categoryController)
                  : categoryController.categoryList!.isEmpty ? const SizedBox() : WebCategoryView(categoryController: categoryController);
            }),

            _isLogin ?  WebVisitAgainView(fromFood: isFood) : const SizedBox(),

            isPharmacy ? const WebBasicMedicineNearbyView()
                : isShop ? const WebMostPopularItemView(isShop: true, isFood: false)
                : const WebSpecialOfferView(isFood: false, isShop: false),

            (isPharmacy || isShop) ? const MiddleSectionMultipleBannerView()
                : isFood ? const WebBestReviewItemView()
                : const WebBestStoreNearbyView(),

            isPharmacy ? const WebBestStoreNearbyView()
                : isFood ? const WebNewOnView(isFood: true)
                : isShop ? const WebPopularStoresView()
                : const WebMostPopularItemView(isFood: false, isShop: false),

            isPharmacy ? const WebJustForYouView()
                : isFood ? const WebItemThatYouLoveView()
                : isShop ? const WebSpecialOfferView(isFood: false, isShop: true)
                : GetBuilder<CampaignController>(builder: (campaignController) {
                  return campaignController.basicCampaignList == null ?  WebMostPopularItemBannerView(campaignController: campaignController)
                  : campaignController.basicCampaignList!.isEmpty ? const SizedBox()
                      : WebMostPopularItemBannerView(campaignController: campaignController);
            }),

            isPharmacy ? const WebNewOnView()
                : isFood ? const WebMostPopularItemView(isFood: true, isShop: false)
                : isShop ? const WebBestReviewItemView()
                : const WebBestReviewItemView(),

            isPharmacy ? const WebCommonConditionView()
                : isFood ? const WebJustForYouView()
                : isShop ? const WebJustForYouView()
                : /*const WebStoreWiseBannerView(),*/ const SizedBox(),

            isPharmacy ? const SizedBox()
                : isFood ? const WebNewOnMartView()
                : isShop ? const  WebFeaturedCategoriesView()
                : const WebJustForYouView(),

            (isPharmacy || isFood) ? const SizedBox() : isShop ? /*const WebStoreWiseBannerView()*/ const SizedBox() : const WebItemThatYouLoveView(),

            (isPharmacy || isFood) ? const SizedBox() : isShop ? const WebItemThatYouLoveForShop() : isLoggedIn ? const WebCouponBannerView() : const SizedBox(),

            (isPharmacy || isFood) ? const SizedBox() : isShop ? const WebNewOnView() : const WebNewOnMartView(),

            isFood ? const SizedBox() : const WebPromotionalBannerView(),

            /*GetBuilder<StoreController>(builder: (storeController) {
              return Column(children: [
                storeController.popularStoreList == null ? WebPopularStoreView(storeController: storeController, isPopular: true)
                    : storeController.popularStoreList!.isEmpty ? const SizedBox() : WebPopularStoreView(storeController: storeController, isPopular: true),

                SizedBox(height: (storeController.popularStoreList != null && storeController.popularStoreList!.isNotEmpty) ? Dimensions.paddingSizeDefault : 0),
              ]);
            }),

            GetBuilder<CampaignController>(builder: (campaignController) {
              return Column(children: [
                campaignController.itemCampaignList == null ? WebCampaignView(campaignController: campaignController)
                    : campaignController.itemCampaignList!.isEmpty ? const SizedBox() : WebCampaignView(campaignController: campaignController),

                SizedBox(height: (campaignController.itemCampaignList != null && campaignController.itemCampaignList!.isNotEmpty) ? Dimensions.paddingSizeDefault : 0),

              ]);
            }),

            GetBuilder<ItemController>(builder: (itemController) {
              return Column(children: [
                itemController.popularItemList == null ? WebPopularItemView(itemController: itemController, isPopular: true)
                    : itemController.popularItemList!.isEmpty ? const SizedBox() : WebPopularItemView(itemController: itemController, isPopular: true),

                SizedBox(height: (itemController.popularItemList != null && itemController.popularItemList!.isNotEmpty) ? Dimensions.paddingSizeLarge : 0),
              ]);
            }),

            GetBuilder<StoreController>(builder: (storeController) {
              return Column(children: [
                storeController.latestStoreList == null ? WebPopularStoreView(storeController: storeController, isPopular: false)
                    : storeController.latestStoreList!.isEmpty ? const SizedBox() : WebPopularStoreView(storeController: storeController, isPopular: false),

                SizedBox(height: (storeController.latestStoreList != null && storeController.latestStoreList!.isNotEmpty) ? Dimensions.paddingSizeDefault : 0),
              ]);
            }),

            GetBuilder<ItemController>(builder: (itemController) {
              return Column(children: [
                itemController.reviewedItemList == null ? WebPopularItemView(itemController: itemController, isPopular: false)
                    : itemController.reviewedItemList!.isEmpty ? const SizedBox() : WebPopularItemView(itemController: itemController, isPopular: false),

                SizedBox(height: (itemController.reviewedItemList != null && itemController.reviewedItemList!.isNotEmpty) ? Dimensions.paddingSizeDefault : 0),
              ]);
            }),*/

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 0, 5),
              child: GetBuilder<StoreController>(builder: (storeController) {
                return Row(children: [
                  Expanded(child: Text(
                    '${storeController.storeModel?.totalSize ?? 0} ${Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'restaurants'.tr : 'stores'.tr}',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  )),
                  /*storeController.storeModel != null ? PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(value: 'all', textStyle: robotoMedium.copyWith(
                          color: storeController.storeType == 'all'
                              ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
                        ), child: Text('all'.tr)),
                        PopupMenuItem(value: 'take_away', textStyle: robotoMedium.copyWith(
                          color: storeController.storeType == 'take_away'
                              ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
                        ), child: Text('take_away'.tr)),
                        PopupMenuItem(value: 'delivery', textStyle: robotoMedium.copyWith(
                          color: storeController.storeType == 'delivery'
                              ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
                        ), child: Text('delivery'.tr)),
                      ];
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Icon(Icons.tune_outlined),
                    ),
                    onSelected: (dynamic value) => storeController.setStoreType(value),
                  ) : const SizedBox(),*/

                  storeController.storeModel != null ? Row(children: [
                    InkWell(
                      onTap: () => storeController.setStoreType('all'),
                      child: StoreSortingButton(
                        storeType: 'all',
                        storeTypeText: 'all'.tr,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    InkWell(
                      onTap: () => storeController.setStoreType('delivery'),
                      child: StoreSortingButton(
                        storeType: 'delivery',
                        storeTypeText: 'delivery'.tr,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    InkWell(
                      onTap: () => storeController.setStoreType('take_away'),
                      child: StoreSortingButton(
                        storeType: 'take_away',
                        storeTypeText: 'take_away'.tr,
                      ),
                    ),
                  ]) : const SizedBox(),
                ]);
              }),
            ),

            GetBuilder<StoreController>(builder: (storeController) {
              return PaginatedListView(
                scrollController: widget.scrollController,
                totalSize: storeController.storeModel != null ? storeController.storeModel!.totalSize : null,
                offset: storeController.storeModel != null ? storeController.storeModel!.offset : null,
                onPaginate: (int? offset) async => await storeController.getStoreList(offset!, false),
                itemView: ItemsView(
                  isStore: true, items: null,
                  stores: storeController.storeModel != null ? storeController.storeModel!.stores : null,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                    vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                  ),
                ),
              );
            }),
          ]))),
        ]),
      ),

      const Positioned(right: 0, top: 0, bottom: 0, child: Center(child: ModuleWidget())),

    ]);
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }
}
