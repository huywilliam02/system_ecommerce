import 'dart:async';

import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/controller/parcel_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/cart_widget.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_dialog.dart';
import 'package:citgroupvn_ecommerce/view/screens/chat/conversation_screen.dart';
import 'package:citgroupvn_ecommerce/view/screens/checkout/widget/congratulation_dialogue.dart';
import 'package:citgroupvn_ecommerce/view/screens/dashboard/widget/address_bottom_sheet.dart';
import 'package:citgroupvn_ecommerce/view/screens/dashboard/widget/bottom_nav_item.dart';
import 'package:citgroupvn_ecommerce/view/screens/dashboard/widget/navbar_custom_painter.dart';
import 'package:citgroupvn_ecommerce/view/screens/dashboard/widget/parcel_bottom_sheet.dart';
import 'package:citgroupvn_ecommerce/view/screens/favourite/favourite_screen.dart';
import 'package:citgroupvn_ecommerce/view/screens/home/home_screen.dart';
import 'package:citgroupvn_ecommerce/view/screens/menu/menu_screen_new.dart';
import 'package:citgroupvn_ecommerce/view/screens/order/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widget/running_order_view_widget.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;
  const DashboardScreen({Key? key, required this.pageIndex, this.fromSplash = false}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;

  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();


  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<AuthController>().isLoggedIn();

    if(_isLogin){
      if(Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 && Get.find<AuthController>().getEarningPint().isNotEmpty
          && !ResponsiveHelper.isDesktop(Get.context)){
        Future.delayed(const Duration(seconds: 1), () => showAnimatedDialog(context, const CongratulationDialogue()));
      }
      suggestAddressBottomSheet();
      Get.find<OrderController>().getRunningOrders(1);
    }

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const FavouriteScreen(),
      const SizedBox(),
      const OrderScreen(),
      const MenuScreenNew()
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if(widget.fromSplash && Get.find<LocationController>().showLocationSuggestion && active) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheet(),
        ).then((value) {
          Get.find<LocationController>().hideSuggestedLocation();
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return WillPopScope(
      onWillPop: () async {
        if (_pageIndex != 0) {
          _setPage(0);
          return false;
        } else {
          if(!ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.module == null) {
            Get.find<SplashController>().setModule(null);
            return false;
          }else {
            if(_canExit) {
              return true;
            }else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              ));
              _canExit = true;
              Timer(const Duration(seconds: 2), () {
                _canExit = false;
              });
              return false;
            }
          }
        }
      },
      child: GetBuilder<OrderController>(
        builder: (orderController) {
          List<OrderModel> runningOrder = orderController.runningOrderModel != null ? orderController.runningOrderModel!.orders! : [];

          List<OrderModel> reversOrder =  List.from(runningOrder.reversed);

          return Scaffold(
            key: _scaffoldKey,
            body: ExpandableBottomSheet(
              background: Stack(children: [
                PageView.builder(
                    controller: _pageController,
                    itemCount: _screens.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _screens[index];
                    },
                  ),

                  ResponsiveHelper.isDesktop(context) || keyboardVisible ? const SizedBox() : Align(
                    alignment: Alignment.bottomCenter,
                    child: GetBuilder<SplashController>(
                      builder: (splashController) {
                        bool isParcel = splashController.module != null && splashController.configModel!.moduleConfig!.module!.isParcel!;

                        _screens = [
                          const HomeScreen(),
                          isParcel ? const ConversationScreen(fromNavBar: true) : const FavouriteScreen(),
                          const SizedBox(),
                          const OrderScreen(),
                          const MenuScreenNew()
                        ];
                        return SizedBox(
                          width: size.width, height: GetPlatform.isIOS ? 95 : 80,
                          child: Stack(children: [
                            CustomPaint(size: Size(size.width, GetPlatform.isIOS ? 95 : 80), painter: BNBCustomPainter()),

                            Center(
                              heightFactor: 0.6,
                              child: ResponsiveHelper.isDesktop(context) ? null : (widget.fromSplash && Get.find<LocationController>().showLocationSuggestion && active) ? null
                                : (orderController.showBottomSheet && orderController.runningOrderModel != null && orderController.runningOrderModel!.orders!.isNotEmpty && _isLogin) ? const SizedBox() : Container(
                                  width: 60, height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  margin: EdgeInsets.only(bottom: GetPlatform.isIOS ? 0 : Dimensions.paddingSizeLarge),
                                  child: FloatingActionButton(
                                    backgroundColor: _pageIndex == 2 ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                    onPressed: () {
                                      if(isParcel) {
                                        showModalBottomSheet(
                                          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                                          builder: (con) => ParcelBottomSheet(parcelCategoryList: Get.find<ParcelController>().parcelCategoryList),
                                        );
                                      } else {
                                        Get.toNamed(RouteHelper.getCartRoute());
                                      }
                                    },
                                    elevation: 5,
                                    child: isParcel
                                        ? Icon(CupertinoIcons.add, size: 34, color: Theme.of(context).primaryColor)
                                        : CartWidget(color: _pageIndex == 2 ? Theme.of(context).cardColor : Theme.of(context).primaryColor, size: 30),
                                  ),
                              ),
                            ),
                            ResponsiveHelper.isDesktop(context) ? const SizedBox() : (widget.fromSplash && Get.find<LocationController>().showLocationSuggestion && active) ? const SizedBox()
                            : (orderController.showBottomSheet && orderController.runningOrderModel != null && orderController.runningOrderModel!.orders!.isNotEmpty && _isLogin) ? const SizedBox() : Center(
                              child: Container(
                                  margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                                  width: size.width, height: 85,
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                    BottomNavItem(title: 'home'.tr, iconData: CupertinoIcons.house_alt_fill, isSelected: _pageIndex == 0, onTap: () => _setPage(0)),
                                    BottomNavItem(title: isParcel ? 'chat'.tr : 'favourite'.tr, iconData: isParcel ? CupertinoIcons.bubble_left_bubble_right_fill : CupertinoIcons.heart_fill, isSelected: _pageIndex == 1, onTap: () => _setPage(1)),
                                    Container(width: size.width * 0.2),
                                    BottomNavItem(title: 'orders'.tr, iconData: CupertinoIcons.bag_fill, isSelected: _pageIndex == 3, onTap: () => _setPage(3)),
                                    BottomNavItem(title: 'menu'.tr, iconData: Icons.menu, isSelected: _pageIndex == 4, onTap: () => _setPage(4)),
                                  ]),
                              ),
                            ),
                          ],
                          ),
                        );
                      }
                    ),
                  ),
                ]),

              persistentContentHeight: (widget.fromSplash && Get.find<LocationController>().showLocationSuggestion && active) ? 0 : 100 ,

              onIsContractedCallback: () {
                if(!orderController.showOneOrder) {
                  orderController.showOrders();
                }
              },
              onIsExtendedCallback: () {
                if(orderController.showOneOrder) {
                  orderController.showOrders();
                }
              },

              enableToggle: true,

              expandableContent: (widget.fromSplash && Get.find<LocationController>().showLocationSuggestion && active && !ResponsiveHelper.isDesktop(context)) ?  const SizedBox()
              : (ResponsiveHelper.isDesktop(context) || !_isLogin || orderController.runningOrderModel == null
              || orderController.runningOrderModel!.orders!.isEmpty || !orderController.showBottomSheet) ? const SizedBox()
              : Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  if(orderController.showBottomSheet){
                    orderController.showRunningOrders();
                  }
                },
                child: RunningOrderViewWidget(reversOrder: reversOrder, onOrderTap: () {
                  _setPage(3);
                  if(orderController.showBottomSheet){
                    orderController.showRunningOrders();
                  }
                }),
              ),
            ),
          );
        }
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(height: 3, decoration: BoxDecoration(color: status ? Theme.of(context).primaryColor
        : Theme.of(context).disabledColor.withOpacity(0.5), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }
}

