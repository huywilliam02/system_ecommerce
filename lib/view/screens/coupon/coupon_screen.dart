
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/coupon_controller.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/view/base/no_data_screen.dart';
import 'package:citgroupvn_ecommerce/view/base/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/base/web_page_title_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/coupon/widget/coupon_card.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({Key? key}) : super(key: key);

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {

  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<CouponController>().getCouponList();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(title: 'coupon'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: isLoggedIn ? GetBuilder<CouponController>(builder: (couponController) {
        return couponController.couponList != null ? couponController.couponList!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            await couponController.getCouponList();
          },
          child: Scrollbar(controller: scrollController, child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                WebScreenTitleWidget(title: 'coupon'.tr),
                Center(child: FooterView(
                  child: SizedBox(width: Dimensions.webMaxWidth, child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                      mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall,
                      childAspectRatio: ResponsiveHelper.isMobile(context) ? 3 : 3,
                    ),
                    itemCount: couponController.couponList!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: couponController.couponList![index].code!));
                          if(!ResponsiveHelper.isDesktop(context)) {
                            showCustomSnackBar('coupon_code_copied'.tr, isError: false);
                          }
                        },
                        child: CouponCard(coupon: couponController.couponList![index], index: index),
                      );
                    },
                  )),
                ))
              ],
            ),
          )),
        ) : NoDataScreen(text: 'no_coupon_found'.tr, showFooter: true) : const Center(child: CircularProgressIndicator());
      }) :  NotLoggedInScreen(callBack: (bool value)  {
        initCall();
        setState(() {});
      }),
    );
  }
}