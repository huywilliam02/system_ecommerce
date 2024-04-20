import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/cart_controller.dart';
import 'package:citgroupvn_ecommerce/controller/category_controller.dart';
import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/wishlist_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/category_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/store_model.dart';
import 'package:citgroupvn_ecommerce/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/item_view.dart';
import 'package:citgroupvn_ecommerce/view/base/item_widget.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/view/base/paginated_list_view.dart';
import 'package:citgroupvn_ecommerce/view/base/veg_filter_widget.dart';
import 'package:citgroupvn_ecommerce/view/base/web_item_view.dart';
import 'package:citgroupvn_ecommerce/view/base/web_item_widget.dart';
import 'package:citgroupvn_ecommerce/view/base/web_menu_bar.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/checkout_screen.dart';
import 'package:citgroupvn_ecommerce/view/screens/search/widget/custom_check_box.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/widget/customizable_space_bar.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/widget/store_banner.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/widget/store_description_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/screens/store/widget/store_details_screen_shimmer_view.dart';

import 'widget/bottom_cart_widget.dart';

class StoreScreen extends StatefulWidget {
  final Store? store;
  final bool fromModule;
  final String slug;
  const StoreScreen({Key? key, required this.store, required this.fromModule, this.slug = ''}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    initDataCall();
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  Future<void> initDataCall() async {
    if(Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
    Get.find<StoreController>().hideAnimation();
    await Get.find<StoreController>().getStoreDetails(Store(id: widget.store!.id), widget.fromModule, slug: widget.slug).then((value) {
      Get.find<StoreController>().showButtonAnimation();
    });
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<StoreController>().getStoreBannerList(widget.store!.id ?? Get.find<StoreController>().store!.id);
    Get.find<StoreController>().getRestaurantRecommendedItemList(widget.store!.id ?? Get.find<StoreController>().store!.id, false);
    Get.find<StoreController>().getStoreItemList(widget.store!.id ?? Get.find<StoreController>().store!.id, 1, 'all', false);

    scrollController.addListener(() {
      if(scrollController.position.userScrollDirection == ScrollDirection.reverse){
        if(Get.find<StoreController>().showFavButton){
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().hideAnimation();
        }
      }else{
        if(!Get.find<StoreController>().showFavButton){
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().showButtonAnimation();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: GetBuilder<StoreController>(builder: (storeController) {
        return GetBuilder<CategoryController>(builder: (categoryController) {
          Store? store;
          if(storeController.store != null && storeController.store!.name != null && categoryController.categoryList != null) {
            store = storeController.store;
            storeController.setCategoryList();
          }

          return (storeController.store != null && storeController.store!.name != null && categoryController.categoryList != null) ? CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: [

              ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFF171A29),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  alignment: Alignment.center,
                  child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Row(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: CustomImage(
                            fit: BoxFit.cover, height: 240, width: 590,
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}/${store!.coverPhoto}',
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(child: StoreDescriptionView(store: store)),

                    ]),
                  ))),
                ),
              ) : SliverAppBar(
                expandedHeight: 300, toolbarHeight: 100,
                pinned: true, floating: false, elevation: 0.5,
                backgroundColor: Theme.of(context).cardColor,
                leading: IconButton(
                  icon: Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                    alignment: Alignment.center,
                    child: Icon(Icons.chevron_left, color: Theme.of(context).cardColor),
                  ),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  centerTitle: true,
                  expandedTitleScale: 1.1,
                  title: CustomizableSpaceBar(
                    builder: (context, scrollingRate) {
                      return Container(
                        height: store!.discount != null ? 145 : 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
                        ),
                        child: Column(
                          children: [
                            store.discount != null ? Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(1 - scrollingRate),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
                              ),
                              padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall - (GetPlatform.isAndroid ? (scrollingRate * Dimensions.paddingSizeExtraSmall) : 0)),
                              child: Text('${store.discount!.discountType == 'percent' ? '${store.discount!.discount}% ${'off'.tr}'
                                  : '${PriceConverter.convertPrice(store.discount!.discount)} ${'off'.tr}'} '
                                  '${'on_all_products'.tr}, ${'after_minimum_purchase'.tr} ${PriceConverter.convertPrice(store.discount!.minPurchase)},'
                                  ' ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(store.discount!.startTime!)} '
                                  '- ${DateConverter.convertTimeToTime(store.discount!.endTime!)}',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.black.withOpacity(1 - scrollingRate),
                                ),
                                textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            ) : const SizedBox(),

                            Container(
                              color: Theme.of(context).cardColor.withOpacity(scrollingRate),
                              padding: EdgeInsets.only(
                                bottom: 0,
                                left: Get.find<LocalizationController>().isLtr ? 40 * scrollingRate : 0,
                                right: Get.find<LocalizationController>().isLtr ? 0 : 40 * scrollingRate,
                              ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  height: 100, color: Theme.of(context).cardColor.withOpacity(scrollingRate == 0.0 ? 1 : 0),
                                  padding: EdgeInsets.only(
                                    left: Get.find<LocalizationController>().isLtr ? 20 : 0,
                                    right: Get.find<LocalizationController>().isLtr ? 0 : 20,
                                  ),
                                  child: Row(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      child: Stack(children: [
                                        CustomImage(
                                          image: '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${store.logo}',
                                          height: 60 - (scrollingRate * 15), width: 70 - (scrollingRate * 15), fit: BoxFit.cover,
                                        ),

                                        storeController.isStoreOpenNow(store.active!, store.schedules) ? const SizedBox() : Positioned(
                                          bottom: 0, left: 0, right: 0,
                                          child: Container(
                                            height: 30,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusSmall)),
                                              color: Colors.black.withOpacity(0.6),
                                            ),
                                            child: Text(
                                              'closed_now'.tr, textAlign: TextAlign.center,
                                              style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),

                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Row(children: [
                                        Expanded(child: Text(
                                          store.name!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge - (scrollingRate * 3), color: Theme.of(context).textTheme.bodyMedium!.color),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        )),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),

                                      ]),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                      Text(
                                        store.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall - (scrollingRate * 2), color: Theme.of(context).disabledColor),
                                      ),
                                      SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0),
                                      Row(children: [
                                        Text('minimum_order'.tr, style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * 2), color: Theme.of(context).disabledColor,
                                        )),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                        Text(
                                          PriceConverter.convertPrice(store.minimumOrder), textDirection: TextDirection.ltr,
                                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall - (scrollingRate * 2), color: Theme.of(context).primaryColor),
                                        ),
                                      ]),
                                    ])),

                                    GetBuilder<WishListController>(builder: (wishController) {
                                      bool isWished = wishController.wishStoreIdList.contains(store!.id);
                                      return InkWell(
                                        onTap: () {
                                          if(Get.find<AuthController>().isLoggedIn()) {
                                            isWished ? wishController.removeFromWishList(store!.id, true)
                                                : wishController.addToWishList(null, store, true);
                                          }else {
                                            showCustomSnackBar('you_are_not_logged_in'.tr);
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          ),
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                          child: Icon(
                                            isWished ? Icons.favorite : Icons.favorite_border,
                                            color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                            size: 24  - (scrollingRate * 4),
                                          ),
                                        ),
                                      );
                                    }),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),

                                    InkWell(
                                      onTap: (){
                                        String shareUrl = '${AppConstants.webHostedUrl}${Get.find<StoreController>().filteringUrl(store!.slug ?? '')}';
                                        Share.share(shareUrl);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        ),
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                        child: Icon(
                                          Icons.share, size: 24  - (scrollingRate * 4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),

                                  ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  background: CustomImage(
                    fit: BoxFit.cover,
                    image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}/${store!.coverPhoto}',
                  ),
                ),
                actions: const [
                  SizedBox(),
                ],
              ),

              (ResponsiveHelper.isDesktop(context)  && storeController.recommendedItemModel != null && storeController.recommendedItemModel!.items!.isNotEmpty)
              ? SliverToBoxAdapter(
                child: Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.10),
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      height: ResponsiveHelper.isDesktop(context) ? 300 : 125,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text('recommended'.tr, style: robotoMedium),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: storeController.recommendedItemModel!.items!.length,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              itemBuilder: (context, index) {
                                return Container(
                                  width:  225,
                                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  child: WebItemWidget(
                                    isStore: false, item: storeController.recommendedItemModel!.items![index],
                                    store: null, index: index, length: null, isCampaign: false, inStore: true,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ): const SliverToBoxAdapter(child: SizedBox()),
              const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeSmall)),

              ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
                child: FooterView(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 175,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: storeController.categoryList!.length,
                                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          storeController.setCategoryIndex(index, itemSearching: storeController.isSearching);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomRight,
                                                end: Alignment.topLeft,
                                                colors: <Color>[
                                                  index == storeController.categoryIndex ? Theme.of(context).primaryColor.withOpacity(0.50) : Colors.transparent,
                                                  index == storeController.categoryIndex ? Theme.of(context).cardColor : Colors.transparent,
                                                ]
                                              )
                                            ),
                                            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              Text(
                                                storeController.categoryList![index].name!,
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                                style: index == storeController.categoryIndex
                                                    ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                                    : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                              ),
                                            ]),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                Container(
                                  height: storeController.categoryList!.length * 50, width: 1,
                                  color: Theme.of(context).disabledColor.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeLarge),

                          Expanded(child: Column (
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                    height: 45,
                                    width: 430,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      color: Theme.of(context).cardColor,
                                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.40)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            textInputAction: TextInputAction.search,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                              hintText: 'search_for_items'.tr,
                                              hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), borderSide: BorderSide.none),
                                              filled: true, fillColor:Theme.of(context).cardColor,
                                              isDense: true,
                                              prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor.withOpacity(0.50)),
                                            ),
                                            onSubmitted: (String? value) {
                                              if(value!.isNotEmpty) {
                                                Get.find<StoreController>().getStoreSearchItemList(
                                                  _searchController.text.trim(), widget.store!.id.toString(), 1, storeController.type,
                                                );
                                              }
                                            } ,
                                            onChanged: (String? value) { } ,
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),

                                        !storeController.isSearching ? CustomButton(
                                          radius: Dimensions.radiusSmall,
                                          height: 40,
                                          width: 74,
                                          buttonText: 'search'.tr,
                                          isBold: false,
                                          fontSize: Dimensions.fontSizeSmall,
                                          onPressed: () {
                                            storeController.getStoreSearchItemList(
                                              _searchController.text.trim(), widget.store!.id.toString(), 1, storeController.type,
                                            );
                                          },
                                        ) : InkWell(onTap: () {
                                          _searchController.text = '';
                                          storeController.initSearchData();
                                          storeController.changeSearchStatus();
                                        },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
                                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: Dimensions.paddingSizeSmall),
                                            child: const Icon(Icons.clear, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                                  ? SizedBox(
                                    width: 300,
                                    height:  30,
                                    child:  ListView.builder(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: Get.find<ItemController>().itemTypeList.length,
                                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          // onTap: () => storeController.setCategoryIndex(index),
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                            child:  CustomCheckBox(
                                              title: Get.find<ItemController>().itemTypeList[index].tr,
                                              value: storeController.type == Get.find<ItemController>().itemTypeList[index],
                                              onClick: () {
                                                if(storeController.isSearching){
                                                  storeController.getStoreSearchItemList(
                                                    storeController.searchText, widget.store!.id.toString(), 1, Get.find<ItemController>().itemTypeList[index],
                                                  );
                                                } else {
                                                  storeController.getStoreItemList(storeController.store!.id, 1, Get.find<ItemController>().itemTypeList[index], true);
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ) : const SizedBox(),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              PaginatedListView(
                                scrollController: scrollController,
                                onPaginate: (int? offset) {
                                  if(storeController.isSearching){
                                    storeController.getStoreSearchItemList(
                                      storeController.searchText, widget.store!.id.toString(), offset!, storeController.type,
                                    );
                                  } else {
                                    storeController.getStoreItemList(widget.store!.id, offset!, storeController.type, false);
                                  }
                                },
                                totalSize: storeController.isSearching
                                    ? storeController.storeSearchItemModel != null ? storeController.storeSearchItemModel!.totalSize : null
                                    : storeController.storeItemModel != null ? storeController.storeItemModel!.totalSize : null,
                                offset: storeController.isSearching
                                    ? storeController.storeSearchItemModel != null ? storeController.storeSearchItemModel!.offset : null
                                    : storeController.storeItemModel != null ? storeController.storeItemModel!.offset : null,
                                itemView: WebItemsView(
                                  isStore: false, stores: null, fromStore: true,
                                  items: storeController.isSearching
                                      ? storeController.storeSearchItemModel != null ? storeController.storeSearchItemModel!.items : null
                                      : (storeController.categoryList!.isNotEmpty && storeController.storeItemModel != null) ? storeController.storeItemModel!.items : null,
                                  inStorePage: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeSmall,
                                  ),
                                ),
                              ),
                            ],
                          ))

                        ],
                      ),
                    ),
                  ),
                ),
              ) : const SliverToBoxAdapter(child:SizedBox()),

              ResponsiveHelper.isDesktop(context) ? const SliverToBoxAdapter(child:SizedBox()) :
              SliverToBoxAdapter(child: Center(child: Container(
                width: Dimensions.webMaxWidth,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                color: Theme.of(context).cardColor,
                child: Column(children: [

                  ResponsiveHelper.isDesktop(context) ? const SizedBox() : StoreDescriptionView(store: store),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  store.announcementActive! ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                    child: Row(children: [
                      Image.asset(Images.announcement, height: 20, width: 20),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Flexible(child: Text(store.announcementMessage!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall))),
                    ]),
                  ) : const SizedBox(),

                  StoreBanner(storeController: storeController),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  (!ResponsiveHelper.isDesktop(context) && storeController.recommendedItemModel != null && storeController.recommendedItemModel!.items!.isNotEmpty) ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('recommended_items'.tr, style: robotoMedium),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 150 : 125,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: storeController.recommendedItemModel!.items!.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 10) ,
                              child: Container(
                                width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
                                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                child: ItemWidget(
                                  isStore: false, item: storeController.recommendedItemModel!.items![index],
                                  store: null, index: index, length: null, isCampaign: false, inStore: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ) : const SizedBox(),
                ]),
              ))),

              ResponsiveHelper.isDesktop(context) ? const SliverToBoxAdapter(child:SizedBox()) :
              (storeController.categoryList!.isNotEmpty) ? SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(height: 90, child: Center(child: Container(
                  width: Dimensions.webMaxWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5)],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        child: Row(children: [
                          Text('all_products'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          const Expanded(child: SizedBox()),

                          !ResponsiveHelper.isDesktop(context) ? InkWell(
                            onTap: ()=> Get.toNamed(RouteHelper.getSearchStoreItemRoute(store!.id)),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(Icons.search, size: 28, color: Theme.of(context).primaryColor),
                            ),
                          ) : const SizedBox(),

                          storeController.type.isNotEmpty ? VegFilterWidget(
                              type: storeController.type,
                              onSelected: (String type) {
                                storeController.getStoreItemList(storeController.store!.id, 1, type, true);
                              },
                          ) : const SizedBox(),

                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      SizedBox(
                        height: 30,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: storeController.categoryList!.length,
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => storeController.setCategoryIndex(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: index == storeController.categoryIndex ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                                ),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text(
                                    storeController.categoryList![index].name!,
                                    style: index == storeController.categoryIndex
                                        ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                        : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ))),
              ) : const SliverToBoxAdapter(child: SizedBox()),

              ResponsiveHelper.isDesktop(context) ? const SliverToBoxAdapter(child:SizedBox()) :
              SliverToBoxAdapter(child: Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                ),
                child: PaginatedListView(
                  scrollController: scrollController,
                  onPaginate: (int? offset) => storeController.getStoreItemList(widget.store!.id, offset!, storeController.type, false),
                  totalSize: storeController.storeItemModel != null ? storeController.storeItemModel!.totalSize : null,
                  offset: storeController.storeItemModel != null ? storeController.storeItemModel!.offset : null,
                  itemView: ItemsView(
                    isStore: false, stores: null,
                    items: (storeController.categoryList!.isNotEmpty && storeController.storeItemModel != null)
                        ? storeController.storeItemModel!.items : null,
                    inStorePage: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                  ),
                ),
              )),
            ],
          ) : const StoreDetailsScreenShimmerView();
        });
      }),

      floatingActionButton: GetBuilder<StoreController>(
        builder: (storeController) {
          return Visibility(
            visible: storeController.showFavButton && Get.find<SplashController>().configModel!.moduleConfig!.module!.orderAttachment!
                && (storeController.store != null && storeController.store!.prescriptionOrder!)
                && Get.find<SplashController>().configModel!.prescriptionStatus! && Get.find<AuthController>().isLoggedIn(),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.5), blurRadius: 10, offset: const Offset(2, 2))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [

                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: storeController.currentState == true ? 0 : ResponsiveHelper.isDesktop(context) ? 180 : 150,
                  height: 30,
                  curve: Curves.linear,
                  child:  Center(
                    child: Text(
                      'prescription_order'.tr, textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                InkWell(
                  onTap: () => Get.toNamed(
                    RouteHelper.getCheckoutRoute('prescription', storeId: storeController.store!.id),
                    arguments: CheckoutScreen(fromCart: false, cartList: null, storeId: storeController.store!.id),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Image.asset(Images.prescriptionIcon, height: 25, width: 25),
                  ),
                ),

              ]),
            ),
          );
        }
      ),

      bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
        return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
      })
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}

class CategoryProduct {
  CategoryModel category;
  List<Item> products;
  CategoryProduct(this.category, this.products);
}

